import TypeEmbeddings.RGB.Core
import Mathlib.Analysis.InnerProductSpace.PiL2

/-! The RGB grid as an exact Cartesian subset of real Euclidean three-space. -/

noncomputable section
namespace TypeEmbeddings

def rgbValue (c : RGB) : EuclideanSpace ℝ (Fin 3) := WithLp.toLp 2 (fun j => channelValue (c j))

theorem rgbValue_injective : Function.Injective rgbValue := by
  intro a b h
  funext j
  apply channelValue_injective
  exact congrArg (fun x : EuclideanSpace ℝ (Fin 3) => x j) h

theorem channelValue_strictMono : StrictMono channelValue := by
  intro a b hab
  have hr : (a.val : ℝ) < (b.val : ℝ) := by exact_mod_cast hab
  unfold channelValue
  linarith

/-- Any two different grid points are separated by at least one full spacing. -/
theorem channelValue_abs_gap (a b : Channel) (hab : a ≠ b) :
    1 / 128 ≤ |channelValue a - channelValue b| := by
  have hval : a.val ≠ b.val := fun h => hab (Fin.ext h)
  rcases lt_or_gt_of_ne hval with hlt | hgt
  · have hnat : a.val + 1 ≤ b.val := Nat.succ_le_of_lt hlt
    have hr : (a.val : ℝ) + 1 ≤ (b.val : ℝ) := by exact_mod_cast hnat
    have hg := channelValue_difference a b
    rw [abs_of_nonpos (sub_nonpos.mpr (le_of_lt (channelValue_strictMono hlt)))]
    linarith
  · have hnat : b.val + 1 ≤ a.val := Nat.succ_le_of_lt hgt
    have hr : (b.val : ℝ) + 1 ≤ (a.val : ℝ) := by exact_mod_cast hnat
    have hg := channelValue_difference b a
    rw [abs_of_nonneg (sub_nonneg.mpr (le_of_lt (channelValue_strictMono hgt)))]
    linarith

theorem rgbValue_norm_sq (c : RGB) (mu : EuclideanSpace ℝ (Fin 3)) :
    ‖rgbValue c - mu‖ ^ 2 = ∑ j, (channelValue (c j) - mu j) ^ 2 := by
  simp [EuclideanSpace.real_norm_sq_eq, rgbValue]

end TypeEmbeddings
