import TypeEmbeddings.Reader.RGBProbability
import Mathlib.Tactic.FieldSimp

/-! Exact common-scale equivalence to normalized reconstruction scores.
The temperature is fixed across candidates at the given hidden state. -/

noncomputable section
namespace TypeEmbeddings

def commonRGBKernel (mu : RGBSpace) (s : ℝ) (c : RGB) : ℝ :=
  ∏ j : Fin 3, channelKernel (mu j) s (c j)

theorem commonRGBKernel_exp (mu : RGBSpace) (s : ℝ) (c : RGB) :
    commonRGBKernel mu s c = Real.exp (-‖rgbValue c - mu‖ ^ 2 / (2 * s ^ 2)) := by
  unfold commonRGBKernel channelKernel channelCost
  rw [← Real.exp_sum]
  congr 1
  rw [← Finset.sum_div, Finset.sum_neg_distrib, ← rgbValue_norm_sq]

theorem commonRGBKernel_sum (mu : RGBSpace) (s : ℝ) :
    ∑ c : RGB, commonRGBKernel mu s c = ∏ j : Fin 3, channelNormalizer (mu j) s := by
  unfold commonRGBKernel channelNormalizer RGB
  rw [← Fintype.prod_sum]

theorem rgbProbability_common_normalized (mu : RGBSpace) (s : ℝ) (c : RGB) :
    rgbProbability mu (fun _ => s) c = commonRGBKernel mu s c / ∑ b, commonRGBKernel mu s b := by
  rw [commonRGBKernel_sum]
  unfold rgbProbability channelProbability commonRGBKernel
  rw [Finset.prod_div_distrib]

def reconstructionKernel {N : ℕ} (w : Fin N → Quaternion ℝ)
    (h : BankSpace N) (s : ℝ) (c : RGB) : ℝ :=
  Real.exp (-‖h - encoder w (rgbValue c)‖ ^ 2 / (2 * bankEnergy w * s ^ 2))

theorem reconstructionKernel_factor {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (h : BankSpace N) (s : ℝ) (hs : 0 < s) (c : RGB) :
    reconstructionKernel w h s c =
      Real.exp (-residualEnergy w h / (2 * bankEnergy w * s ^ 2)) *
        commonRGBKernel (analyticDecoder w h) s c := by
  rw [commonRGBKernel_exp, ← Real.exp_add]
  unfold reconstructionKernel residualEnergy
  rw [reconstruction_score w hS]
  congr 1
  field_simp
  ring

/-- Exact likelihood identity; no candidate-dependent temperature is allowed. -/
theorem rgb_reconstruction_likelihood {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (h : BankSpace N) (s : ℝ) (hs : 0 < s) (c : RGB) :
    reconstructionKernel w h s c / ∑ b, reconstructionKernel w h s b =
      rgbProbability (analyticDecoder w h) (fun _ => s) c := by
  simp_rw [reconstructionKernel_factor w hS h s hs]
  rw [← Finset.mul_sum, rgbProbability_common_normalized]
  exact mul_div_mul_left _ _ (ne_of_gt (Real.exp_pos _))

theorem rgbReader_reconstruction_likelihood {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (h : BankSpace N) (c : RGB) :
    reconstructionKernel w h (residualScale w p h) c /
      ∑ b, reconstructionKernel w h (residualScale w p h) b = rgbReaderProbability w p h c :=
  rgb_reconstruction_likelihood w hS h _ (residualScale_pos w hS p h) c

def readerTemperature {N : ℕ} (w : Fin N → Quaternion ℝ)
    (p : WidthParameters) (h : BankSpace N) : ℝ :=
  2 * bankEnergy w * residualVariance w p h

theorem readerTemperature_pos {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (h : BankSpace N) :
    0 < readerTemperature w p h :=
  mul_pos (mul_pos (by norm_num) hS) (residualVariance_pos w hS p h)

theorem rgbReader_reconstruction_temperature {N : ℕ} (w : Fin N → Quaternion ℝ)
    (hS : 0 < bankEnergy w) (p : WidthParameters) (h : BankSpace N) (c : RGB) :
    Real.exp (-‖h - encoder w (rgbValue c)‖ ^ 2 / readerTemperature w p h) /
      (∑ b : RGB, Real.exp (-‖h - encoder w (rgbValue b)‖ ^ 2 / readerTemperature w p h)) =
        rgbReaderProbability w p h c := by
  simpa only [reconstructionKernel, residualScale_sq w hS p h, readerTemperature] using
    rgbReader_reconstruction_likelihood w hS p h c

end TypeEmbeddings
