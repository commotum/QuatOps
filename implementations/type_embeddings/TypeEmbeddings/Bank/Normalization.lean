import TypeEmbeddings.Bank.Basic

/-! Exact real normalization of a nonzero bank to fixed positive energy. -/

noncomputable section
namespace TypeEmbeddings

theorem bankEnergy_smul {N : ℕ} (w : Fin N → Quaternion ℝ) (r : ℝ) :
    bankEnergy (fun i => r • w i) = r ^ 2 * bankEnergy w := by
  rw [bankEnergy_eq_sum_norm_sq, bankEnergy_eq_sum_norm_sq]
  simp_rw [norm_smul, Real.norm_eq_abs, mul_pow, sq_abs]
  exact (Finset.mul_sum _ _ _).symm

def normalizedBank {N : ℕ} (v : Fin N → Quaternion ℝ) (target : ℝ) :
    Fin N → Quaternion ℝ := fun i =>
  (Real.sqrt target / Real.sqrt (bankEnergy v)) • v i

theorem normalizedBank_energy {N : ℕ} (v : Fin N → Quaternion ℝ)
    (hv : 0 < bankEnergy v) (target : ℝ) (ht : 0 ≤ target) :
    bankEnergy (normalizedBank v target) = target := by
  unfold normalizedBank
  rw [bankEnergy_smul, div_pow,
    Real.sq_sqrt ht, Real.sq_sqrt hv.le]
  exact div_mul_cancel₀ target (ne_of_gt hv)

theorem normalizedBank_pos {N : ℕ} (v : Fin N → Quaternion ℝ)
    (hv : 0 < bankEnergy v) (target : ℝ) (ht : 0 < target) :
    0 < bankEnergy (normalizedBank v target) := by
  rw [normalizedBank_energy v hv target ht.le]
  exact ht

end TypeEmbeddings
