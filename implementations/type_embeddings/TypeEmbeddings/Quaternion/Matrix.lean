import TypeEmbeddings.Quaternion.Core
import Mathlib.LinearAlgebra.Matrix.Notation

/-! The real 4×4 matrix of right multiplication in scalar/i/j/k order. -/

noncomputable section
namespace TypeEmbeddings

/-- Column-coordinate matrix for q ↦ q*w; this is right, not left, multiplication. -/
def rightMulMatrix (w : Quaternion ℝ) : Matrix (Fin 4) (Fin 4) ℝ :=
  !![w.re, -w.imI, -w.imJ, -w.imK;
     w.imI, w.re, w.imK, -w.imJ;
     w.imJ, -w.imK, w.re, w.imI;
     w.imK, w.imJ, -w.imI, w.re]

theorem rightMulMatrix_apply (w q : Quaternion ℝ) :
    (rightMulMatrix w).mulVec (Quaternion.equivTuple ℝ q) =
      Quaternion.equivTuple ℝ (rightMulLinear w q) := by
  ext i
  fin_cases i <;>
    simp [rightMulMatrix, Matrix.mulVec, dotProduct, Fin.sum_univ_four,
      Quaternion.equivTuple_apply, rightMulLinear] <;> ring

/-- Block Gram identity, valid also at w=0. -/
theorem rightMul_gram (w : Quaternion ℝ) :
    (rightMulMatrix w).transpose * rightMulMatrix w =
      Quaternion.normSq w • (1 : Matrix (Fin 4) (Fin 4) ℝ) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [rightMulMatrix, Matrix.mul_apply, Matrix.transpose_apply,
      Fin.sum_univ_four, Quaternion.normSq_def'] <;> ring

end TypeEmbeddings
