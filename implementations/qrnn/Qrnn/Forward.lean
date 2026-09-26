import Qrnn.ActivationCore

/-!
# QRNN and QLSTM forward architectures

`hidden 0` is the supplied initial state. Input `x k` drives step `k+1`.
This is the paper recurrence reindexed to avoid an undefined state at time -1.
The QRNN readout has no bias, matching the printed equations. Architectures are
separate from derivative correctness and from empirical performance claims.
-/

namespace Qrnn
noncomputable section

/-- Parameters of the printed one-layer quaternion RNN. -/
structure QRNNParams (d h o : ℕ) where
  recurrent : QMatrix h h
  input : QMatrix h d
  output : QMatrix o h
  bias : QVector h

/-- Hidden preactivation; weights act on the left. -/
def hiddenPreact {d h o : ℕ} (p : QRNNParams d h o) (x : QVector d) (s : QVector h) :
    QVector h := p.recurrent.mulVec s + p.input.mulVec x + p.bias

/-- A single forward step with a scalar split activation. -/
def qrnnStep {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : QVector d) (s : QVector h) : QVector h :=
  vectorActivation f (hiddenPreact p x s)

/-- The split-activation output specified by the paper. Coupled softmax is a separate head. -/
def qrnnReadout {d h o : ℕ} (p : QRNNParams d h o) (β : ℝ → ℝ) (s : QVector h) :
    QVector o := vectorActivation β (p.output.mulVec s)

/-- Unrolled recurrence. `x k` drives `hidden (k+1)` from `hidden k`. -/
def qrnnRun {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) : ℕ → QVector h
  | 0 => initial
  | k + 1 => qrnnStep p f (x k) (qrnnRun p f x initial k)

@[simp] theorem qrnnRun_zero {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) : qrnnRun p f x initial 0 = initial := rfl

@[simp] theorem qrnnRun_succ {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) (k : ℕ) :
    qrnnRun p f x initial (k+1) = qrnnStep p f (x k) (qrnnRun p f x initial k) := rfl

/-- Inputs outside the prefix cannot affect the state at its endpoint. -/
theorem qrnnRun_prefix {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x y : ℕ → QVector d) (initial : QVector h) (T : ℕ)
    (hxy : ∀ k < T, x k = y k) : qrnnRun p f x initial T = qrnnRun p f y initial T := by
  induction T with
  | zero => rfl
  | succ T ih =>
    rw [qrnnRun_succ, qrnnRun_succ, hxy T (Nat.lt_succ_self T)]
    rw [ih (fun k hk => hxy k (Nat.lt_trans hk (Nat.lt_succ_self T)))]

/-- Finite-horizon interface: exactly T inputs and T+1 hidden states. -/
def qrnnFiniteRun {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ) (T : ℕ)
    (x : Fin T → QVector d) (initial : QVector h) : Fin (T+1) → QVector h :=
  fun t => qrnnRun p f (fun k => if hk : k < T then x ⟨k, hk⟩ else 0) initial t.val

/-- Real split activation on the explicit neuron/component coordinates. -/
def realVectorActivation {n : ℕ} (f : ℝ → ℝ) (v : Fin n × Fin 4 → ℝ) :
    Fin n × Fin 4 → ℝ := fun i => f (v i)

@[simp] theorem vectorComponents_add {n : ℕ} (v w : QVector n) :
    vectorComponents (v+w) = vectorComponents v + vectorComponents w := by
  funext ⟨i, a⟩
  exact congrFun (components_add (v i) (w i)) a

@[simp] theorem vectorActivation_components {n : ℕ} (f : ℝ → ℝ) (v : QVector n) :
    vectorComponents (vectorActivation f v) = realVectorActivation f (vectorComponents v) := by
  funext ⟨i, a⟩
  exact congrFun (components_splitActivation f (v i)) a

/-- Structured real implementation, keeping the quaternion weight sharing. -/
def realQRNNStep {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : Fin d × Fin 4 → ℝ) (s : Fin h × Fin 4 → ℝ) : Fin h × Fin 4 → ℝ :=
  realVectorActivation f ((expand p.recurrent).mulVec s +
    (expand p.input).mulVec x + vectorComponents p.bias)

theorem qrnnStep_expand {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : QVector d) (s : QVector h) :
    vectorComponents (qrnnStep p f x s) =
      realQRNNStep p f (vectorComponents x) (vectorComponents s) := by
  simp [qrnnStep, hiddenPreact, realQRNNStep, ← expand_apply]

/-- Independently unrolled real-coordinate recurrence. -/
def realQRNNRun {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : ℕ → Fin d × Fin 4 → ℝ) (initial : Fin h × Fin 4 → ℝ) :
    ℕ → Fin h × Fin 4 → ℝ
  | 0 => initial
  | k + 1 => realQRNNStep p f (x k) (realQRNNRun p f x initial k)

theorem qrnnRun_expand {d h o : ℕ} (p : QRNNParams d h o) (f : ℝ → ℝ)
    (x : ℕ → QVector d) (initial : QVector h) (T : ℕ) :
    vectorComponents (qrnnRun p f x initial T) =
      realQRNNRun p f (fun k => vectorComponents (x k)) (vectorComponents initial) T := by
  induction T with
  | zero => rfl
  | succ T ih => simp only [qrnnRun_succ, realQRNNRun, qrnnStep_expand, ih]

/-- One affine map of a QLSTM gate/candidate. -/
structure GateParams (d h : ℕ) where
  input : QMatrix h d
  recurrent : QMatrix h h
  bias : QVector h

/-- Four independent gate/candidate affine maps, without an output head. -/
structure QLSTMParams (d h : ℕ) where
  forget : GateParams d h
  input : GateParams d h
  candidate : GateParams d h
  output : GateParams d h

/-- Gate affine operation; the omitted Hamilton symbols in the paper's candidate
term are interpreted consistently with the other three gate maps. -/
def gatePreact {d h : ℕ} (p : GateParams d h) (x : QVector d) (s : QVector h) :
    QVector h := p.input.mulVec x + p.recurrent.mulVec s + p.bias

/-- Explicit componentwise product of quaternion vectors. -/
def vectorHadamard {h : ℕ} (v w : QVector h) : QVector h := fun i => hadamard (v i) (w i)

/-- `(cell, hidden)` update with chosen scalar gate and candidate/cell activations.
Instantiating `τ` with real tanh gives the printed split-tanh equations. No QLSTM
backpropagation, optimization, or recognition-performance theorem is asserted. -/
def qlstmStep {d h : ℕ} (p : QLSTMParams d h) (α τ : ℝ → ℝ)
    (x : QVector d) (state : QVector h × QVector h) : QVector h × QVector h :=
  let f := vectorActivation α (gatePreact p.forget x state.2)
  let i := vectorActivation α (gatePreact p.input x state.2)
  let o := vectorActivation α (gatePreact p.output x state.2)
  let candidate := vectorActivation τ (gatePreact p.candidate x state.2)
  let cell := vectorHadamard f state.1 + vectorHadamard i candidate
  (cell, vectorHadamard o (vectorActivation τ cell))

end
end Qrnn
