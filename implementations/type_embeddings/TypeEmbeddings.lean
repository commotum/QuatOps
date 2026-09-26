import TypeEmbeddings.Quaternion.Basic
import TypeEmbeddings.Quaternion.Matrix
import TypeEmbeddings.Bank.Matrix
import TypeEmbeddings.Bank.LeastSquares
import TypeEmbeddings.Bank.Spectral
import TypeEmbeddings.Bank.Normalization
import TypeEmbeddings.RGB.Decoding
import TypeEmbeddings.RGB.Rounding
import TypeEmbeddings.RGB.EvenDecoding
import TypeEmbeddings.Probability.PMF
import TypeEmbeddings.Probability.EvenMode
import TypeEmbeddings.Counts.Cost
import TypeEmbeddings.Reader.Gain
import TypeEmbeddings.TypeCode.PMF
import TypeEmbeddings.Reader.Summary
import TypeEmbeddings.Probability.Reconstruction
import TypeEmbeddings.Typed.Interface
import TypeEmbeddings.Typed.Probability
import TypeEmbeddings.Counts.Structured
import TypeEmbeddings.Counts.StructuredCost
import TypeEmbeddings.Text.Decoder
import TypeEmbeddings.Text.Spectral
import TypeEmbeddings.Text.Distribution
import TypeEmbeddings.Text.Resolve

/-! Public mathematical API. Internal leaves import specific prerequisites.
Diagnostics are checked separately and are not public dependencies. -/
