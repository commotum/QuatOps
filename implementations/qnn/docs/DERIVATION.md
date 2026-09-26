# Verified reconstruction of the learning rule

The supplied source gives the forward model, one-output squared error and four
real-component gradient updates. It does not print hidden-layer recurrences or
explicit weight partials. The following is an independent real-calculus
reconstruction, proved by the declarations referenced here.

Write C_w(x) = w x star(w), n = ‖w‖ and A_w(x) = n⁻¹ C_w(x). For w ≠ 0,
with h an arbitrary real quaternion perturbation,

```text
D_w A_w(x)[h] = n⁻¹ • (w x star(h) + h x star(w))
                − (innerℝ(w,h) / n³) • (w x star(w)).
```

`weightAction_hasFDerivAt` proves that this is a real Fréchet derivative;
`weightDerivative_apply` proves the displayed ordered formula. Both the
conjugated weight and the denominator are differentiated. Treating the
normalization factor as constant would omit the second line and change the
learning rule. Multiplication is never commuted.

`activation_hasFDerivAt` supplies the three-coordinate diagonal Jacobian, with
slope sigmoid(sᵢ)(1 − sigmoid(sᵢ)). `neuronInput_hasFDerivAt` and
`Network.input_hasFDerivAt` compose these with the fixed-weight linear input
maps. `Network.pullback` is a recursive reverse pass on real dual spaces;
`pullback_hasFDerivAt` proves it computes the scalar objective's input differential.
Euclidean signal spaces `Signal n` are used whenever gradients/adjoints are taken.

For weight learning, `Network.WeightIndex` addresses every connection in every
layer. `e.replace a` changes that actual quaternion weight and keeps all other
parameters fixed. `e.hasFDerivAt` proves the resulting complete-network forward
map has derivative `e.derivative x` at `e.value ≠ 0`. In an earlier layer,
this derivative composes the weight sensitivity with each downstream input
Jacobian. The reverse recursion `e.backprop x δ` applies those downstream
adjoints in reverse order; `e.backprop_eq` proves it equals the adjoint of the
complete forward sensitivity. No downstream derivative is guessed or assumed.

`signalLoss_eq_outputLoss` identifies the explicit finite-output sum of the
source's displayed errors with half the squared Euclidean output norm.
`signalLoss_hasGradientAt` proves the seed δ = y − d. Then
`Network.weightGradient_hasGradientAt` proves, for every weight address,

```text
∇_w (signalLoss (forward (network with w replaced)) d)
  = e.backprop x (forward N x − d).
```

The four-component interpretation is also checked as an actual coordinate
partial: `componentPartial_hasDerivAt` differentiates the scalar path
E(w + t • parameterBasis i) at t = 0. This is real multivariable calculus,
not quaternion analyticity or a left/right quaternion derivative.

`Network.mapWeights_parametric_differentiableAt` additionally proves the full
forward computation is differentiable when all weights and the input vary jointly
in a supplied real normed parameter space. Coordinate weight maps must be
differentiable, and their values nonzero at the point. The neuron-level theorem
also permits a varying threshold. `objective_parametric_differentiableAt` proves
the corresponding squared-error objective is differentiable.

`Network.trainStep` simultaneously applies each original-network weight gradient.
Its address transport `updatedIndex` lets a caller inspect the new value at the
same architecture position. `trainStep_components` proves exactly

```text
new weight component = old weight component − η • its real coordinate partial
```

at every layer when the original network is admissible (all weights nonzero).
The theorem does not require η > 0 because it proves the update equation itself.
It does not assert objective decrease, convergence or admissibility of the new
network. Thresholds stay fixed: their training is not specified in the source.
The finite-output sum is labeled as an extension; with one output it reduces
to the displayed source loss. No dataset batching or averaging convention is
attributed to the source, and no experimental training implementation is recovered.

The illustrative 16-4-16 network in `Examples/Autoencoder.lean` instantiates the
full hidden-weight update theorem; its all-one weights are not the paper's weights.
