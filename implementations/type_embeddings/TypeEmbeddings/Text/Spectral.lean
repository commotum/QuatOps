import TypeEmbeddings.Text.Counts
import Mathlib.Analysis.InnerProductSpace.SingularValues

/-! Spectral and score-family dimension facts, isolated from core algebra. -/

noncomputable section
open scoped RealInnerProductSpace
namespace TypeEmbeddings.Text

variable {J : Type*} [Fintype J] {n : J → ℕ}

theorem groupedAdjoint_eq (w : ∀ j, Fin (n j) → Quaternion ℝ) :
    (groupedEncoder w).adjoint = groupedAdjoint w := by
  apply LinearMap.ext
  intro h
  apply ext_inner_left ℝ
  intro q
  rw [LinearMap.adjoint_inner_right, groupedAdjoint_pairing]

theorem groupedUnit_rank (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, groupEnergy w j = 1) :
    Module.finrank ℝ (LinearMap.range (groupedEncoder w)) = mrWidth (J := J) := by
  rw [LinearMap.finrank_range_of_inj (groupedEncoder_injective w (fun j => by rw [hS j]; norm_num)),
    mrSpace_finrank]

theorem groupedUnit_singularValue (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, groupEnergy w j = 1) (i : ℕ) (hi : i < mrWidth (J := J)) :
    (groupedEncoder w).singularValues i = 1 := by
  have hdim : Module.finrank ℝ (MRSpace J) = mrWidth (J := J) := mrSpace_finrank
  obtain ⟨v, hv⟩ := ((groupedEncoder w).hasEigenvalue_adjoint_comp_self_sq_singularValues
    (hdim ▸ hi)).exists_hasEigenvector
  have he := Module.End.mem_eigenspace_iff.mp hv.1
  change (groupedEncoder w).adjoint (groupedEncoder w v) =
    (groupedEncoder w).singularValues i ^ 2 • v at he
  rw [groupedAdjoint_eq, groupedUnit_roundTrip w hS] at he
  have he' : (1 : ℝ) • v = (groupedEncoder w).singularValues i ^ 2 • v := by
    simpa only [one_smul] using he
  have hs := smul_left_injective ℝ hv.2 he'
  apply (sq_eq_sq₀ ((groupedEncoder w).singularValues_nonneg i) zero_le_one).mp
  simpa only [one_pow] using hs.symm

theorem grouped_singularValue_tail (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (i : ℕ) (hi : mrWidth (J := J) ≤ i) : (groupedEncoder w).singularValues i = 0 := by
  apply (groupedEncoder w).singularValues_of_finrank_le
  rwa [mrSpace_finrank]

theorem groupedUnit_opNorm [Nonempty J] (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, groupEnergy w j = 1) : ‖(groupedEncoder w).toContinuousLinearMap‖ = 1 := by
  apply ContinuousLinearMap.homothety_norm
  intro q
  change ‖groupedEncoder w q‖ = 1 * ‖q‖
  simpa only [one_mul] using groupedUnit_norm w hS q

/-- With a fixed dictionary, logits depend linearly on the r-coordinate query. -/
def dictionaryScoreMap {V : Type*} (dictionary : V → MRSpace J) : MRSpace J →ₗ[ℝ] (V → ℝ) where
  toFun q := fun v => ⟪dictionary v, q⟫
  map_add' q r := by funext v; exact inner_add_right _ _ _
  map_smul' a q := by
    funext v
    simp only [inner_smul_right, Pi.smul_apply, smul_eq_mul, RingHom.id_apply]

theorem dictionaryScore_rank_le {V : Type*} (dictionary : V → MRSpace J) :
    Module.finrank ℝ (LinearMap.range (dictionaryScoreMap dictionary)) ≤ mrWidth (J := J) := by
  rw [← mrSpace_finrank]
  exact LinearMap.finrank_range_le (dictionaryScoreMap dictionary)

end TypeEmbeddings.Text
