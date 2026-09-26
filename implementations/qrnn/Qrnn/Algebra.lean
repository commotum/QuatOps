import Mathlib.Analysis.Quaternion
import Mathlib.LinearAlgebra.Matrix.ConjTranspose
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FinCases

/-!
# Quaternion coordinates and the two Hamilton multiplication matrices

Coordinates are `(r,i,j,k)`. `leftBlock q` acts by `x ↦ q*x`, whereas
`rightBlock q` acts by `x ↦ x*q`. Their composition orders differ.
All differentiation will be over ℝ; component packaging asserts no quaternion
holomorphic derivative. Componentwise products are separately named.
-/

namespace Qrnn

open scoped Quaternion

abbrev Q := Quaternion ℝ

/-- Quaternion vectors count quaternion units, not real coordinates. -/
abbrev QVector (n : ℕ) := Fin n → Q
abbrev QMatrix (m n : ℕ) := Matrix (Fin m) (Fin n) Q

noncomputable section

/-- The existing mathlib coordinate equivalence, in `(r,i,j,k)` order. -/
def components (q : Q) : Fin 4 → ℝ := Quaternion.equivTuple ℝ q

/-- Reconstruct a quaternion from its four real coordinates. -/
def ofComponents (v : Fin 4 → ℝ) : Q := (Quaternion.equivTuple ℝ).symm v

@[simp] theorem ofComponents_components (q : Q) : ofComponents (components q) = q :=
  (Quaternion.equivTuple ℝ).symm_apply_apply q

@[simp] theorem components_ofComponents (v : Fin 4 → ℝ) :
    components (ofComponents v) = v :=
  (Quaternion.equivTuple ℝ).apply_symm_apply v

theorem components_injective : Function.Injective components :=
  (Quaternion.equivTuple ℝ).injective

@[simp] theorem components_zero : components 0 = 0 := by
  ext a; fin_cases a <;> simp [components, Quaternion.equivTuple_apply]

@[simp] theorem components_add (p q : Q) : components (p + q) = components p + components q := by
  ext a; fin_cases a <;> simp [components, Quaternion.equivTuple_apply]

@[simp] theorem components_sum {ι : Type*} (s : Finset ι) (f : ι → Q) :
    components (∑ i ∈ s, f i) = ∑ i ∈ s, components (f i) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | @insert a s ha ih => simp [Finset.sum_insert, ha, ih]

/-- The paper's Hamilton product, using mathlib's ordered multiplication. -/
theorem hamilton_components (p q : Q) : components (p * q) =
    ![p.re*q.re - p.imI*q.imI - p.imJ*q.imJ - p.imK*q.imK,
      p.re*q.imI + p.imI*q.re + p.imJ*q.imK - p.imK*q.imJ,
      p.re*q.imJ - p.imI*q.imK + p.imJ*q.re + p.imK*q.imI,
      p.re*q.imK + p.imI*q.imJ - p.imJ*q.imI + p.imK*q.re] := by
  ext a; fin_cases a <;> simp [components, Quaternion.equivTuple_apply]

/-- Left multiplication by `q`. This is `Q_mat` in §3.1. -/
def leftBlock (q : Q) : Matrix (Fin 4) (Fin 4) ℝ :=
  !![q.re, -q.imI, -q.imJ, -q.imK;
     q.imI, q.re, -q.imK, q.imJ;
     q.imJ, q.imK, q.re, -q.imI;
     q.imK, -q.imJ, q.imI, q.re]

/-- Right multiplication by `q`; it is generally different from `leftBlock q`. -/
def rightBlock (q : Q) : Matrix (Fin 4) (Fin 4) ℝ :=
  !![q.re, -q.imI, -q.imJ, -q.imK;
     q.imI, q.re, q.imK, -q.imJ;
     q.imJ, -q.imK, q.re, q.imI;
     q.imK, q.imJ, -q.imI, q.re]

theorem leftBlock_apply (q x : Q) :
    (leftBlock q).mulVec (components x) = components (q * x) := by
  ext a; fin_cases a <;>
    simp [leftBlock, Matrix.mulVec, dotProduct, Fin.sum_univ_four,
      components, Quaternion.equivTuple_apply] <;> ring

theorem rightBlock_apply (q x : Q) :
    (rightBlock q).mulVec (components x) = components (x * q) := by
  ext a; fin_cases a <;>
    simp [rightBlock, Matrix.mulVec, dotProduct, Fin.sum_univ_four,
      components, Quaternion.equivTuple_apply] <;> ring

theorem leftBlock_mul (p q : Q) : leftBlock (p * q) = leftBlock p * leftBlock q := by
  ext a b; fin_cases a <;> fin_cases b <;>
    simp [leftBlock, Matrix.mul_apply, Fin.sum_univ_four] <;> ring

/-- Right multiplication is an anti-representation. -/
theorem rightBlock_mul (p q : Q) : rightBlock (p * q) = rightBlock q * rightBlock p := by
  ext a b; fin_cases a <;> fin_cases b <;>
    simp [rightBlock, Matrix.mul_apply, Fin.sum_univ_four] <;> ring

theorem leftBlock_star (q : Q) : leftBlock (star q) = (leftBlock q).transpose := by
  ext a b; fin_cases a <;> fin_cases b <;> simp [leftBlock, Matrix.transpose_apply]

theorem rightBlock_star (q : Q) : rightBlock (star q) = (rightBlock q).transpose := by
  ext a b; fin_cases a <;> fin_cases b <;> simp [rightBlock, Matrix.transpose_apply]

/-- Neuron-major real coordinates; the type has exactly `4*n` coordinates. -/
def vectorComponents {n : ℕ} (v : QVector n) : Fin n × Fin 4 → ℝ :=
  fun i => components (v i.1) i.2

/-- A quaternion `m×n` matrix expands to `(m×4)×(n×4)` real coordinates. -/
def expand {m n : ℕ} (W : QMatrix m n) : Matrix (Fin m × Fin 4) (Fin n × Fin 4) ℝ :=
  fun i j => leftBlock (W i.1 j.1) i.2 j.2

theorem expand_apply {m n : ℕ} (W : QMatrix m n) (x : QVector n) :
    (expand W).mulVec (vectorComponents x) = vectorComponents (W.mulVec x) := by
  ext ⟨i, a⟩
  simp only [Matrix.mulVec, dotProduct, vectorComponents, expand,
    Fintype.sum_prod_type, components_sum, Finset.sum_apply]
  apply Finset.sum_congr rfl
  intro j _
  exact congrFun (leftBlock_apply (W i j) (x j)) a

@[simp] theorem leftBlock_add (p q : Q) : leftBlock (p + q) = leftBlock p + leftBlock q := by
  ext a b; fin_cases a <;> fin_cases b <;> simp [leftBlock, add_comm]

@[simp] theorem leftBlock_zero : leftBlock 0 = 0 := by
  ext a b; fin_cases a <;> fin_cases b <;> simp [leftBlock]

@[simp] theorem leftBlock_sum {ι : Type*} (s : Finset ι) (f : ι → Q) :
    leftBlock (∑ i ∈ s, f i) = ∑ i ∈ s, leftBlock (f i) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | @insert a s ha ih => simp [Finset.sum_insert, ha, ih]

theorem expand_mul {m n k : ℕ} (W : QMatrix m n) (V : QMatrix n k) :
    expand (W * V) = expand W * expand V := by
  ext ⟨i, a⟩ ⟨j, b⟩
  simp only [expand, Matrix.mul_apply, leftBlock_sum, Matrix.sum_apply,
    Fintype.sum_prod_type]
  apply Finset.sum_congr rfl
  intro l _
  exact congrFun (congrFun (leftBlock_mul (W i l) (V l j)) a) b

/-- The real transpose corresponds to quaternion conjugate transpose. -/
theorem expand_conjTranspose {m n : ℕ} (W : QMatrix m n) :
    expand W.conjTranspose = (expand W).transpose := by
  ext ⟨i, a⟩ ⟨j, b⟩
  exact congrFun (congrFun (leftBlock_star (W j i)) a) b

/-- Euclidean real pairing, not a quaternion-valued inner product. -/
def realPair (p q : Q) : ℝ := ∑ a, components p a * components q a

/-- Cotangent pullback for left multiplication. -/
theorem left_mul_pair (w x g : Q) : realPair (w * x) g = realPair x (star w * g) := by
  simp [realPair, Fin.sum_univ_four, components, Quaternion.equivTuple_apply]
  ring

/-- Cotangent of a left weight uses right multiplication by the input conjugate. -/
theorem weight_mul_pair (w x g : Q) : realPair (w * x) g = realPair w (g * star x) := by
  simp [realPair, Fin.sum_univ_four, components, Quaternion.equivTuple_apply]
  ring

/-- Componentwise product for gates and split activation cotangents. -/
def hadamard (p q : Q) : Q := ofComponents (fun a => components p a * components q a)

@[simp] theorem components_hadamard (p q : Q) :
    components (hadamard p q) = fun a => components p a * components q a :=
  components_ofComponents _

/-- Total normalization; a unit-norm conclusion requires a nonzero input. -/
def normalize (q : Q) : Q := (‖q‖⁻¹ : ℝ) • q

theorem normalize_norm (q : Q) (hq : q ≠ 0) : ‖normalize q‖ = 1 := by
  simp [normalize, norm_smul, norm_ne_zero_iff.mpr hq]

@[simp] theorem normalize_zero : normalize 0 = 0 := by simp [normalize]

end
end Qrnn
