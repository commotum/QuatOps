import TypeEmbeddings.Counts.Basic
import Mathlib.Analysis.Asymptotics.Defs

/-! A scalar-multiplication-slot cost model for straightforward coordinate evaluation.
The counts describe the displayed expressions, not compiled code or hardware latency.
Sums, signs, and loads have bounded work per slot; their inclusion preserves linearity. -/

namespace TypeEmbeddings

/-- Four encoder outputs, three nonzero input coordinates, in each block. -/
abbrev EncoderProductSlots (N : ℕ) := Fin N × (Fin 4 × Fin 3)
/-- Three imaginary output votes, four hidden-state coordinates, in each block. -/
abbrev DecoderVoteSlots (N : ℕ) := Fin N × (Fin 3 × Fin 4)
/-- Four squared-weight terms per block when computing actual bank energy. -/
abbrev EnergyProductSlots (N : ℕ) := Fin N × Fin 4

/-- Slot counts for pure-input encoder multiplication. -/
def encoderProductCount (N : ℕ) : ℕ := Fintype.card (EncoderProductSlots N)
/-- Fused imaginary products, energy squares, and three final scale multiplications.
One scalar reciprocal and bounded work per product/addition are treated separately. -/
def decoderProductCount (N : ℕ) : ℕ :=
  Fintype.card (DecoderVoteSlots N) + Fintype.card (EnergyProductSlots N) + 3

theorem encoderProductCount_eq (N : ℕ) : encoderProductCount N = 12 * N := by
  simp [encoderProductCount, EncoderProductSlots]
  omega

theorem decoderProductCount_eq (N : ℕ) : decoderProductCount N = 16 * N + 3 := by
  simp [decoderProductCount, DecoderVoteSlots, EnergyProductSlots]
  omega

/-- In units of d=4N, encoding has three multiplication slots per output coordinate. -/
theorem encoderProductCount_dimension (N : ℕ) : encoderProductCount N = 3 * (4 * N) := by
  rw [encoderProductCount_eq]

/-- For nonempty banks the fixed readout overhead is bounded by a linear term. -/
theorem decoderProductCount_dimension_bound (N : ℕ) (hN : 1 ≤ N) :
    decoderProductCount N ≤ 5 * (4 * N) := by
  rw [decoderProductCount_eq]
  omega

open Asymptotics Filter

/-- O(d) under the stated multiplication-slot model; not a wall-clock bound. -/
theorem encoder_cost :
    (fun N : ℕ => (encoderProductCount N : ℝ)) =O[atTop] (fun N : ℕ => (4 * N : ℝ)) := by
  apply IsBigO.of_bound 3
  apply Filter.Eventually.of_forall
  intro N
  rw [encoderProductCount_eq]
  simp only [Nat.cast_mul, Nat.cast_ofNat, Real.norm_eq_abs,
    abs_of_nonneg (Nat.cast_nonneg _), abs_mul, abs_ofNat]
  exact le_of_eq (by ring)

theorem decoder_cost :
    (fun N : ℕ => (decoderProductCount N : ℝ)) =O[atTop] (fun N : ℕ => (4 * N : ℝ)) := by
  apply IsBigO.of_bound 5
  filter_upwards [Filter.eventually_ge_atTop (1 : ℕ)] with N hN
  have h := decoderProductCount_dimension_bound N hN
  have hr : (decoderProductCount N : ℝ) ≤ 5 * (4 * (N : ℝ)) := by exact_mod_cast h
  simpa only [Real.norm_eq_abs, abs_of_nonneg (Nat.cast_nonneg _), abs_mul,
    abs_ofNat] using hr

end TypeEmbeddings
