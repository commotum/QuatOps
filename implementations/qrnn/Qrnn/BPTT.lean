import Qrnn.Loss

/-!
# Real finite-horizon backpropagation through time

The reusable core handles a shared parameter and a fixed initial state in any
real normed spaces. Cotangents are continuous real-linear functionals. Backward
propagation composes Jacobian pullbacks; it never multiplies already propagated
error vectors together. QRNN-specific instantiation is recorded separately.
-/

namespace Qrnn
noncomputable section

section General
variable {P H : Type*} [NormedAddCommGroup P] [NormedSpace ℝ P]
  [NormedAddCommGroup H] [NormedSpace ℝ H]

/-- A shared-parameter recurrence. Step index k goes from state k to state k+1. -/
def unroll (step : ℕ → P → H → H) (initial : H) : ℕ → P → H
  | 0 => fun _ => initial
  | k+1 => fun p => step k p (unroll step initial k p)

/-- Partial parameter/state Jacobians combined on the product domain. -/
def jointStepDerivative (A : P →L[ℝ] H) (B : H →L[ℝ] H) : (P × H) →L[ℝ] H :=
  A.comp (ContinuousLinearMap.fst ℝ P H) + B.comp (ContinuousLinearMap.snd ℝ P H)

@[simp] theorem jointStepDerivative_apply (A : P →L[ℝ] H) (B : H →L[ℝ] H)
    (v : P × H) : jointStepDerivative A B v = A v.1 + B v.2 := rfl

/-- Any real-linear joint derivative decomposes into its two partial maps. -/
theorem split_joint_derivative (J : (P × H) →L[ℝ] H) :
    jointStepDerivative (J.comp (ContinuousLinearMap.inl ℝ P H))
      (J.comp (ContinuousLinearMap.inr ℝ P H)) = J := by
  apply DFunLike.ext
  rintro ⟨p, h⟩
  change J (p, 0) + J (0, h) = J (p, h)
  rw [← map_add]
  simp

/-- Parameter partial of a joint derivative in its declared normed structures. -/
def parameterPartial (J : (P × H) →L[ℝ] H) : P →L[ℝ] H :=
  J.comp (ContinuousLinearMap.inl ℝ P H)

/-- State partial of a joint derivative in its declared normed structures. -/
def statePartial (J : (P × H) →L[ℝ] H) : H →L[ℝ] H :=
  J.comp (ContinuousLinearMap.inr ℝ P H)

theorem split_joint_partials (J : (P × H) →L[ℝ] H) :
    jointStepDerivative (parameterPartial J) (statePartial J) = J :=
  split_joint_derivative J

/-- Forward sensitivity to the parameter, with zero initial-state derivative. -/
def unrollDerivative (A : ℕ → P →L[ℝ] H) (B : ℕ → H →L[ℝ] H) : ℕ → P →L[ℝ] H
  | 0 => 0
  | k+1 => A k + (B k).comp (unrollDerivative A B k)

/-- Full real chain rule for the unrolled recurrence, assuming the actual joint
step derivatives at the visited states. Hypotheses do not assert convergence. -/
theorem unroll_hasFDerivAt (step : ℕ → P → H → H) (initial : H) (p : P)
    (A : ℕ → P →L[ℝ] H) (B : ℕ → H →L[ℝ] H) (T : ℕ)
    (hs : ∀ k < T, HasFDerivAt (fun z : P × H => step k z.1 z.2)
      (jointStepDerivative (A k) (B k)) (p, unroll step initial k p)) :
    HasFDerivAt (unroll step initial T) (unrollDerivative A B T) p := by
  induction T with
  | zero => exact hasFDerivAt_const (𝕜 := ℝ) initial p
  | succ T ih =>
    have hp := ih (fun k hk => hs k (Nat.lt_trans hk (Nat.lt_succ_self T)))
    convert! (hs T (Nat.lt_succ_self T)).comp p ((hasFDerivAt_id p).prodMk hp) using 1

/-- Reverse pullback of a terminal cotangent. The recursion visits steps T-1..0;
local parameter contributions are accumulated exactly once per visited step. -/
def bpttPullback (A : ℕ → P →L[ℝ] H) (B : ℕ → H →L[ℝ] H) :
    ℕ → (H →L[ℝ] ℝ) → P →L[ℝ] ℝ
  | 0, _ => 0
  | k+1, g => bpttPullback A B k (g.comp (B k)) + g.comp (A k)

/-- Reverse BPTT equals the forward sensitivity followed by the loss cotangent. -/
theorem bptt_correct (A : ℕ → P →L[ℝ] H) (B : ℕ → H →L[ℝ] H)
    (T : ℕ) (g : H →L[ℝ] ℝ) :
    bpttPullback A B T g = g.comp (unrollDerivative A B T) := by
  induction T generalizing g with
  | zero => simp [bpttPullback, unrollDerivative]
  | succ T ih =>
    simp [bpttPullback, unrollDerivative, ih, ContinuousLinearMap.comp_add,
      ContinuousLinearMap.comp_assoc, add_comm]

/-- Correctness as the derivative of an actual terminal loss, not merely an
identity between two stipulated sensitivity algorithms. -/
theorem terminalLoss_hasFDerivAt (step : ℕ → P → H → H) (initial : H) (p : P)
    (A : ℕ → P →L[ℝ] H) (B : ℕ → H →L[ℝ] H) (T : ℕ)
    (loss : H → ℝ) (g : H →L[ℝ] ℝ)
    (hs : ∀ k < T, HasFDerivAt (fun z : P × H => step k z.1 z.2)
      (jointStepDerivative (A k) (B k)) (p, unroll step initial k p))
    (hl : HasFDerivAt loss g (unroll step initial T p)) :
    HasFDerivAt (fun θ => loss (unroll step initial T θ)) (bpttPullback A B T g) p := by
  rw [bptt_correct]
  exact hl.comp p (unroll_hasFDerivAt step initial p A B T hs)

/-- Finite sums of per-time losses differentiate to sums of their BPTT pullbacks.
Including loss at time 0 is safe: its parameter derivative is zero for fixed initial state. -/
theorem sequenceLoss_hasFDerivAt (step : ℕ → P → H → H) (initial : H) (p : P)
    (A : ℕ → P →L[ℝ] H) (B : ℕ → H →L[ℝ] H) (times : Finset ℕ)
    (loss : ℕ → H → ℝ) (g : ℕ → H →L[ℝ] ℝ)
    (hs : ∀ t ∈ times, ∀ k < t, HasFDerivAt (fun z : P × H => step k z.1 z.2)
      (jointStepDerivative (A k) (B k)) (p, unroll step initial k p))
    (hl : ∀ t ∈ times, HasFDerivAt (loss t) (g t) (unroll step initial t p)) :
    HasFDerivAt (fun θ => ∑ t ∈ times, loss t (unroll step initial t θ))
      (∑ t ∈ times, bpttPullback A B t (g t)) p :=
  HasFDerivAt.fun_sum (fun t ht =>
    terminalLoss_hasFDerivAt step initial p A B t (loss t) (g t) (hs t ht) (hl t ht))

end General
end
end Qrnn
