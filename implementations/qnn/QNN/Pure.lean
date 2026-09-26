import QNN.Algebra
import Mathlib.LinearAlgebra.CrossProduct
import Mathlib.Analysis.InnerProductSpace.PiL2

/-! Pure quaternions as a real subspace, with explicit Euclidean coordinates. -/
noncomputable section
namespace QNN
open scoped Matrix

def pureSubspace : Submodule ℝ H where
  carrier := {q | q.re = 0}
  zero_mem' := rfl
  add_mem' := by intro a b ha hb; simpa using congrArg₂ (· + ·) ha hb
  smul_mem' := by
    intro r q hq
    change q.re = 0 at hq
    simp [Quaternion.re_smul, hq]

abbrev Pure := pureSubspace

@[simp] theorem pure_re (v : Pure) : (v : H).re = 0 := v.property

@[ext] theorem pure_ext {v w : Pure} (h : (v : H) = (w : H)) : v = w := Subtype.ext h

/-- Coordinates always have the ordered axes i,j,k. -/
def vector (q : H) : Fin 3 → ℝ := ![q.imI, q.imJ, q.imK]

def ofVector (v : Fin 3 → ℝ) : Pure := ⟨⟨0, v 0, v 1, v 2⟩, rfl⟩

@[simp] theorem vector_ofVector (v : Fin 3 → ℝ) : vector (ofVector v) = v := by
  funext i; fin_cases i <;> rfl

@[simp] theorem ofVector_vector (v : Pure) : ofVector (vector v) = v := by
  apply pure_ext
  apply Quaternion.ext <;> simp [ofVector, vector]

/-- Orthogonal projection onto the imaginary components, with pure codomain. -/
def pureProjection : H →ₗ[ℝ] Pure where
  toFun q := ofVector (vector q)
  map_add' q r := by apply pure_ext; ext <;> simp [ofVector, vector]
  map_smul' r q := by apply pure_ext; ext <;> simp [ofVector, vector]

@[simp] theorem pureProjection_pure (v : Pure) : pureProjection v = v := ofVector_vector v

/-- Algebraic coordinate equivalence; the raw function space has a different norm. -/
def pureCoordinates : Pure ≃ₗ[ℝ] (Fin 3 → ℝ) where
  toFun v := vector v
  invFun := ofVector
  left_inv := ofVector_vector
  right_inv := vector_ofVector
  map_add' v w := by funext i; fin_cases i <;> rfl
  map_smul' r v := by funext i; fin_cases i <;> rfl

/-- The geometric equivalence uses the Euclidean, rather than supremum, norm. -/
def pureEuclidean : Pure ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin 3) :=
  { pureCoordinates.trans (WithLp.linearEquiv 2 ℝ (Fin 3 → ℝ)).symm with
    norm_map' := by
      intro v
      apply (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
      rw [EuclideanSpace.real_norm_sq_eq]
      change (∑ i : Fin 3, (vector v i) ^ 2) = ‖(v : H)‖ ^ 2
      rw [norm_sq_components]
      simp [vector, Fin.sum_univ_succ, add_assoc] }

instance : CompleteSpace Pure := FiniteDimensional.complete ℝ Pure

/-- Euclidean dot product of imaginary coordinates, also defined for general quaternions. -/
def dot (u v : H) : ℝ := vector u ⬝ᵥ vector v

/-- Oriented cross product in the pure subspace. -/
def cross (u v : H) : Pure := ofVector (vector u ⨯₃ vector v)

theorem dot_components (u v : H) :
    dot u v = u.imI * v.imI + u.imJ * v.imJ + u.imK * v.imK := by
  simp [dot, vector, add_assoc]

/-- Pure multiplication separates into the negative dot product and cross product. -/
theorem pure_mul (u v : Pure) :
    (u : H) * (v : H) = (-dot u v : ℝ) + (cross u v : H) := by
  ext <;> simp [Quaternion.re_mul, Quaternion.imI_mul, Quaternion.imJ_mul,
    Quaternion.imK_mul, dot_components, cross, ofVector, vector, cross_apply] <;> ring

theorem pure_inner (u v : Pure) : inner ℝ u v = dot u v := by
  change inner ℝ (u : H) (v : H) = _
  rw [Quaternion.inner_def]
  simp [Quaternion.re_mul, dot_components]

@[simp] theorem dot_self (v : Pure) : dot v v = ‖v‖ ^ 2 := by
  rw [← pure_inner, real_inner_self_eq_norm_sq]

@[simp] theorem pure_star (v : Pure) : star (v : H) = -(v : H) :=
  Quaternion.star_eq_neg.mpr v.property
end QNN
