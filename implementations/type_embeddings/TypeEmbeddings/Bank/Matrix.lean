import TypeEmbeddings.Quaternion.Matrix
import TypeEmbeddings.Bank.Basic

/-! Stacked real-coordinate matrices, with rows indexed by block and coordinate. -/

noncomputable section
namespace TypeEmbeddings

/-- Stack the 4×4 right-multiplication blocks without a flattening convention. -/
def stackedMatrix {N : ℕ} (w : Fin N → Quaternion ℝ) :
    Matrix (Fin N × Fin 4) (Fin 4) ℝ := fun p j => rightMulMatrix (w p.1) p.2 j

/-- Insert zero as the scalar coordinate. -/
def pureMatrix : Matrix (Fin 4) (Fin 3) ℝ :=
  !![0, 0, 0; 1, 0, 0; 0, 1, 0; 0, 0, 1]

/-- The proposal's B=AP, in real coordinates. -/
def encoderMatrix {N : ℕ} (w : Fin N → Quaternion ℝ) :
    Matrix (Fin N × Fin 4) (Fin 3) ℝ := stackedMatrix w * pureMatrix

theorem stacked_gram {N : ℕ} (w : Fin N → Quaternion ℝ) :
    (stackedMatrix w).transpose * stackedMatrix w =
      bankEnergy w • (1 : Matrix (Fin 4) (Fin 4) ℝ) := by
  ext i j
  simp only [Matrix.mul_apply, Matrix.transpose_apply, stackedMatrix,
    Fintype.sum_prod_type]
  have block (k : Fin N) :
      (∑ a : Fin 4, rightMulMatrix (w k) a i * rightMulMatrix (w k) a j) =
        Quaternion.normSq (w k) * (1 : Matrix (Fin 4) (Fin 4) ℝ) i j := by
    simpa [Matrix.mul_apply, Matrix.transpose_apply] using
      congrArg (fun m : Matrix (Fin 4) (Fin 4) ℝ => m i j) (rightMul_gram (w k))
  simp_rw [block]
  simp [bankEnergy, Finset.sum_mul]

theorem pureMatrix_gram : pureMatrix.transpose * pureMatrix = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [pureMatrix, Matrix.mul_apply, Matrix.transpose_apply, Fin.sum_univ_four]

/-- Literal real-matrix BᵀB=S I₃. -/
theorem encoderMatrix_gram {N : ℕ} (w : Fin N → Quaternion ℝ) :
    (encoderMatrix w).transpose * encoderMatrix w =
      bankEnergy w • (1 : Matrix (Fin 3) (Fin 3) ℝ) := by
  rw [encoderMatrix, Matrix.transpose_mul, Matrix.mul_assoc,
    ← Matrix.mul_assoc (stackedMatrix w).transpose, stacked_gram]
  simp [Matrix.mul_smul, Matrix.smul_mul, pureMatrix_gram]

/-- B's action agrees with the quaternion encoder in every output block. -/
theorem encoderMatrix_apply {N : ℕ} (w : Fin N → Quaternion ℝ) (x : RGBSpace)
    (i : Fin N) (j : Fin 4) :
    (encoderMatrix w).mulVec (WithLp.ofLp x) (i, j) =
      Quaternion.equivTuple ℝ (encoder w x i) j := by
  have hp : pureMatrix.mulVec (WithLp.ofLp x) = Quaternion.equivTuple ℝ (pureRGB x) := by
    ext k
    fin_cases k <;>
      simp [pureMatrix, pureRGB, pureRGBLinear, Quaternion.equivTuple_apply,
        Matrix.mulVec, dotProduct, Fin.sum_univ_three]
  rw [encoderMatrix, ← Matrix.mulVec_mulVec, hp]
  change (rightMulMatrix (w i)).mulVec (Quaternion.equivTuple ℝ (pureRGB x)) j = _
  rw [rightMulMatrix_apply]
  rfl

/-- Analytic pseudoinverse matrix for the pure RGB encoder. -/
def decoderMatrix {N : ℕ} (w : Fin N → Quaternion ℝ) :
    Matrix (Fin 3) (Fin N × Fin 4) ℝ := (bankEnergy w)⁻¹ • (encoderMatrix w).transpose

theorem decoderMatrix_leftInverse {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) : decoderMatrix w * encoderMatrix w = 1 := by
  rw [decoderMatrix, Matrix.smul_mul, encoderMatrix_gram, smul_smul]
  simp [ne_of_gt hS]

end TypeEmbeddings
