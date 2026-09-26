import Qrnn.Loss

/-! Kernel-reported dependencies of the main completed results.
No project axioms are introduced here. Add unrolled BPTT/initialization/count
results when they are implemented; this audit currently covers local results.
-/

#print axioms Qrnn.hamilton_components
#print axioms Qrnn.leftBlock_apply
#print axioms Qrnn.rightBlock_apply
#print axioms Qrnn.leftBlock_mul
#print axioms Qrnn.rightBlock_mul
#print axioms Qrnn.expand_apply
#print axioms Qrnn.expand_mul
#print axioms Qrnn.expand_conjTranspose
#print axioms Qrnn.matrix_mul_pair
#print axioms Qrnn.matrix_weight_pair
#print axioms Qrnn.expand_injective
#print axioms Qrnn.normalize_norm
#print axioms Qrnn.splitActivation_hasFDerivAt
#print axioms Qrnn.qrnnRun_prefix
#print axioms Qrnn.qrnnStep_expand
#print axioms Qrnn.qrnnRun_expand
#print axioms Qrnn.qrnnStep_state_hasFDerivAt
#print axioms Qrnn.recurrentWeight_hasFDerivAt
#print axioms Qrnn.inputWeight_hasFDerivAt
#print axioms Qrnn.bias_hasFDerivAt
#print axioms Qrnn.layerWeight_hasFDerivAt
#print axioms Qrnn.readoutDerivative_pair
#print axioms Qrnn.halfSquaredLoss_hasFDerivAt
#print axioms Qrnn.outputLoss_hasFDerivAt
#print axioms Qrnn.output_gradient
