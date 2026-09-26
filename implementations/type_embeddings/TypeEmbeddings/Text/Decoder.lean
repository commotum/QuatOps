import TypeEmbeddings.Text.Grouped
import TypeEmbeddings.Bank.Normalization
import Mathlib.Tactic.Abel
import Mathlib.Tactic.Linarith

/-! The inverse divides by group energy; the tied scoring adjoint does not.
They agree for unit-energy groups in exact arithmetic. -/

noncomputable section
open scoped RealInnerProductSpace
namespace TypeEmbeddings.Text

variable {J : Type*} [Fintype J] {n : J → ℕ}

def groupedInverse (w : ∀ j, Fin (n j) → Quaternion ℝ) : OutputSpace n →ₗ[ℝ] MRSpace J :=
  (WithLp.linearEquiv 2 ℝ (J → Quaternion ℝ)).symm.toLinearMap.comp
    (LinearMap.pi fun j => ((groupEnergy w j)⁻¹ • (PiLp.projₗ 2 _ j)).comp (groupedAdjoint w))

omit [Fintype J] in
theorem groupedInverse_apply (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (h : OutputSpace n) (j : J) :
    groupedInverse w h j = (groupEnergy w j)⁻¹ • groupedAdjoint w h j := rfl

theorem groupedInverse_roundTrip (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, 0 < groupEnergy w j) (q : MRSpace J) :
    groupedInverse w (groupedEncoder w q) = q := by
  apply (WithLp.ext_iff 2).mpr
  funext j
  change groupedInverse w (groupedEncoder w q) j = q j
  rw [groupedInverse_apply, groupedGram_apply, smul_smul,
    inv_mul_cancel₀ (ne_of_gt (hS j)), one_smul]

theorem groupedEncoder_injective (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, 0 < groupEnergy w j) : Function.Injective (groupedEncoder w) :=
  (show Function.LeftInverse (groupedInverse w) (groupedEncoder w) from
    groupedInverse_roundTrip w hS).injective

def normalizedGroups (u : ∀ j, Fin (n j) → Quaternion ℝ) : ∀ j, Fin (n j) → Quaternion ℝ :=
  fun j => normalizedBank (u j) 1

omit [Fintype J] in
theorem normalizedGroups_unit (u : ∀ j, Fin (n j) → Quaternion ℝ)
    (hu : ∀ j, 0 < groupEnergy u j) (j : J) : groupEnergy (normalizedGroups u) j = 1 := by
  exact normalizedBank_energy (u j) (hu j) 1 zero_le_one

omit [Fintype J] in
theorem group_nonempty (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, 0 < groupEnergy w j) (j : J) : 0 < n j := by
  obtain ⟨i, _⟩ := (bankEnergy_pos_iff (w j)).mp (hS j)
  exact lt_of_le_of_lt (Nat.zero_le i.val) i.isLt

theorem groupedInverse_eq_adjoint (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, groupEnergy w j = 1) : groupedInverse w = groupedAdjoint w := by
  apply LinearMap.ext
  intro h
  apply (WithLp.ext_iff 2).mpr
  funext j
  change groupedInverse w h j = groupedAdjoint w h j
  rw [groupedInverse_apply, hS j, inv_one, one_smul]

theorem groupedUnit_gram (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, groupEnergy w j = 1) :
    (groupedAdjoint w).comp (groupedEncoder w) = LinearMap.id := by
  apply LinearMap.ext
  intro q
  apply (WithLp.ext_iff 2).mpr
  funext j
  change groupedAdjoint w (groupedEncoder w q) j = q j
  rw [groupedGram_apply, hS j, one_smul]

theorem groupedUnit_roundTrip (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, groupEnergy w j = 1) (q : MRSpace J) :
    groupedAdjoint w (groupedEncoder w q) = q :=
  congrArg (fun f : MRSpace J →ₗ[ℝ] MRSpace J => f q) (groupedUnit_gram w hS)

theorem groupedUnit_inner (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, groupEnergy w j = 1) (q r : MRSpace J) :
    ⟪groupedEncoder w q, groupedEncoder w r⟫ = ⟪q, r⟫ := by
  rw [groupedEncoder_inner, PiLp.inner_apply]
  simp_rw [hS, one_mul]

theorem groupedUnit_norm (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, groupEnergy w j = 1) (q : MRSpace J) : ‖groupedEncoder w q‖ = ‖q‖ := by
  rw [norm_eq_sqrt_real_inner, norm_eq_sqrt_real_inner, groupedUnit_inner w hS]

/-- First Moore–Penrose identity for the unit-energy adjoint reader. -/
theorem groupedUnit_penrose_encoder (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, groupEnergy w j = 1) :
    (groupedEncoder w).comp ((groupedAdjoint w).comp (groupedEncoder w)) = groupedEncoder w := by
  rw [groupedUnit_gram w hS, LinearMap.comp_id]

/-- Second Moore–Penrose identity. -/
theorem groupedUnit_penrose_reader (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, groupEnergy w j = 1) :
    (groupedAdjoint w).comp ((groupedEncoder w).comp (groupedAdjoint w)) = groupedAdjoint w := by
  rw [← LinearMap.comp_assoc, groupedUnit_gram w hS, LinearMap.id_comp]

/-- Third Moore–Penrose identity: AAᵀ is self-adjoint, without energy assumptions. -/
theorem groupedProjection_symmetric (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (h k : OutputSpace n) :
    ⟪groupedEncoder w (groupedAdjoint w h), k⟫ =
      ⟪h, groupedEncoder w (groupedAdjoint w k)⟫ := by
  rw [groupedAdjoint_pairing, real_inner_comm (groupedEncoder w (groupedAdjoint w k)) h,
    groupedAdjoint_pairing, real_inner_comm]

/-- Fourth Moore–Penrose identity: AᵀA is the identity. -/
theorem groupedUnit_inverse_symmetric (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, groupEnergy w j = 1) (q r : MRSpace J) :
    ⟪groupedAdjoint w (groupedEncoder w q), r⟫ =
      ⟪q, groupedAdjoint w (groupedEncoder w r)⟫ := by
  rw [groupedUnit_roundTrip w hS, groupedUnit_roundTrip w hS]

def groupedResidual (w : ∀ j, Fin (n j) → Quaternion ℝ) (h : OutputSpace n) : OutputSpace n :=
  h - groupedEncoder w (groupedInverse w h)

theorem groupedResidual_adjoint_zero (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, 0 < groupEnergy w j) (h : OutputSpace n) :
    groupedAdjoint w (groupedResidual w h) = 0 := by
  apply (WithLp.ext_iff 2).mpr
  funext j
  change groupedAdjoint w (groupedResidual w h) j = 0
  rw [groupedResidual, map_sub]
  change groupedAdjoint w h j - groupedAdjoint w (groupedEncoder w (groupedInverse w h)) j = 0
  rw [groupedGram_apply, groupedInverse_apply, smul_smul,
    mul_inv_cancel₀ (ne_of_gt (hS j)), one_smul, sub_self]

theorem groupedResidual_orthogonal (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, 0 < groupEnergy w j) (h : OutputSpace n) (q : MRSpace J) :
    ⟪groupedResidual w h, groupedEncoder w q⟫ = 0 := by
  rw [real_inner_comm (groupedEncoder w q), groupedAdjoint_pairing,
    groupedResidual_adjoint_zero w hS, inner_zero_right]

theorem grouped_reconstruction_score (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, 0 < groupEnergy w j) (h : OutputSpace n) (q : MRSpace J) :
    ‖h - groupedEncoder w q‖ ^ 2 = ‖groupedResidual w h‖ ^ 2 +
      ‖groupedEncoder w (q - groupedInverse w h)‖ ^ 2 := by
  have split : h - groupedEncoder w q =
      groupedResidual w h + groupedEncoder w (groupedInverse w h - q) := by
    rw [groupedResidual, map_sub]
    abel
  rw [split, norm_add_sq_real, groupedResidual_orthogonal w hS,
    map_sub, map_sub, norm_sub_rev]
  ring

theorem groupedInverse_unique_leastSquares (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, 0 < groupEnergy w j) (h : OutputSpace n) (q : MRSpace J) :
    ‖h - groupedEncoder w q‖ ^ 2 = ‖groupedResidual w h‖ ^ 2 ↔ q = groupedInverse w h := by
  rw [grouped_reconstruction_score w hS]
  constructor
  · intro he
    have hn : ‖groupedEncoder w (q - groupedInverse w h)‖ ^ 2 = 0 := by linarith only [he]
    have hz := norm_eq_zero.mp (sq_eq_zero_iff.mp hn)
    have hq : q - groupedInverse w h = 0 := (groupedEncoder_injective w hS)
      (hz.trans (map_zero (groupedEncoder w)).symm)
    exact sub_eq_zero.mp hq
  · intro hq
    simp only [hq, sub_self, map_zero, norm_zero, zero_pow (by decide : 2 ≠ 0), add_zero]

theorem groupedInverse_leastSquares (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (hS : ∀ j, 0 < groupEnergy w j) (h : OutputSpace n) (q : MRSpace J) :
    ‖groupedResidual w h‖ ^ 2 ≤ ‖h - groupedEncoder w q‖ ^ 2 := by
  rw [grouped_reconstruction_score w hS]
  exact le_add_of_nonneg_right (sq_nonneg _)

end TypeEmbeddings.Text
