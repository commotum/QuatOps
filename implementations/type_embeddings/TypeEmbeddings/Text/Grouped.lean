import TypeEmbeddings.Quaternion.Basic
import Mathlib.Data.Fintype.BigOperators

/-! Disjoint groups of full quaternion inputs, with real Euclidean geometry.
Unlike the RGB encoder, the scalar quaternion coordinate is retained. -/

noncomputable section
open scoped RealInnerProductSpace
namespace TypeEmbeddings.Text

abbrev MRSpace (J : Type*) := PiLp 2 (fun _ : J => Quaternion ℝ)
abbrev OutputIndex {J : Type*} (n : J → ℕ) := Sigma fun j => Fin (n j)
abbrev OutputSpace {J : Type*} (n : J → ℕ) := PiLp 2 (fun _ : OutputIndex n => Quaternion ℝ)

variable {J : Type*} [Fintype J] {n : J → ℕ}

def groupEnergy (w : ∀ j, Fin (n j) → Quaternion ℝ) (j : J) : ℝ :=
  ∑ i, Quaternion.normSq (w j i)

def groupedEncoder (w : ∀ j, Fin (n j) → Quaternion ℝ) : MRSpace J →ₗ[ℝ] OutputSpace n :=
  (WithLp.linearEquiv 2 ℝ (OutputIndex n → Quaternion ℝ)).symm.toLinearMap.comp
    (LinearMap.pi fun p => (rightMulLinear (w p.1 p.2)).comp (PiLp.projₗ 2 _ p.1))

def groupedAdjoint (w : ∀ j, Fin (n j) → Quaternion ℝ) : OutputSpace n →ₗ[ℝ] MRSpace J :=
  (WithLp.linearEquiv 2 ℝ (J → Quaternion ℝ)).symm.toLinearMap.comp
    (LinearMap.pi fun j => ∑ i : Fin (n j),
      (rightMulLinear (star (w j i))).comp (PiLp.projₗ 2 _ ⟨j, i⟩))

omit [Fintype J] in
theorem groupedEncoder_apply (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (q : MRSpace J) (j : J) (i : Fin (n j)) :
    groupedEncoder w q ⟨j, i⟩ = q j * w j i := rfl

omit [Fintype J] in
theorem groupedAdjoint_apply (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (h : OutputSpace n) (j : J) :
    groupedAdjoint w h j = ∑ i, h ⟨j, i⟩ * star (w j i) := by
  simp [groupedAdjoint, rightMulLinear]

omit [Fintype J] in
/-- The exact unnormalized Gram is diagonal with one energy per four-dimensional group. -/
theorem groupedGram_apply (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (q : MRSpace J) (j : J) :
    groupedAdjoint w (groupedEncoder w q) j = groupEnergy w j • q j := by
  rw [groupedAdjoint_apply]
  change (∑ i, rightMulLinear (star (w j i)) (rightMulLinear (w j i) (q j))) = _
  simp_rw [rightMul_conjugate]
  rw [← Finset.sum_smul]
  rfl

/-- The scoring adjoint identity requires no normalization or nonzero-weight assumption. -/
theorem groupedAdjoint_pairing (w : ∀ j, Fin (n j) → Quaternion ℝ)
    (q : MRSpace J) (h : OutputSpace n) :
    ⟪groupedEncoder w q, h⟫ = ⟪q, groupedAdjoint w h⟫ := by
  rw [PiLp.inner_apply, PiLp.inner_apply, Fintype.sum_sigma]
  apply Finset.sum_congr rfl
  intro j _
  rw [groupedAdjoint_apply, inner_sum]
  apply Finset.sum_congr rfl
  intro i _
  exact rightMul_adjoint_pairing (w j i) (q j) (h ⟨j, i⟩)

theorem groupedEncoder_inner (w : ∀ j, Fin (n j) → Quaternion ℝ) (q r : MRSpace J) :
    ⟪groupedEncoder w q, groupedEncoder w r⟫ = ∑ j, groupEnergy w j * ⟪q j, r j⟫ := by
  rw [groupedAdjoint_pairing, PiLp.inner_apply]
  simp_rw [groupedGram_apply, inner_smul_right]

end TypeEmbeddings.Text
