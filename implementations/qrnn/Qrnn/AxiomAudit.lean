import Qrnn.QRNNGradients
import Qrnn.BPTTAudit
import Qrnn.InitializationGaussian
import Qrnn.InitializationUniform
import Qrnn.InitializationAudit

/-! Kernel-reported dependencies of the main completed results.
No project axioms are introduced here. Add unrolled BPTT/initialization/count
results when they are implemented; this audit covers algebra, local calculus, generic BPTT, and QRNN state-loss results.
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

#print axioms Qrnn.matVec_hasFDerivAt
#print axioms Qrnn.unroll_hasFDerivAt
#print axioms Qrnn.bptt_correct
#print axioms Qrnn.terminalLoss_hasFDerivAt
#print axioms Qrnn.sequenceLoss_hasFDerivAt
#print axioms Qrnn.split_joint_partials
#print axioms Qrnn.qrnnStep_joint_hasFDerivAt
#print axioms Qrnn.qrnnRun_hasFDerivAt
#print axioms Qrnn.qrnnBptt_correct
#print axioms Qrnn.qrnnTerminalStateLoss_hasFDerivAt

#print axioms Qrnn.qrnnJointDerivative_apply
#print axioms Qrnn.qrnnParameterPartial_apply
#print axioms Qrnn.qrnnStatePartial_apply
#print axioms Qrnn.qrnnParameterDerivative_pair
#print axioms Qrnn.quaternionBpttGradient_correct
#print axioms Qrnn.quaternionBpttGradient_output_zero
#print axioms Qrnn.qrnnTerminalLoss_hasFDerivAt
#print axioms Qrnn.qrnnTerminalGradient_correct
#print axioms Qrnn.qrnnSequenceLoss_hasFDerivAt
#print axioms Qrnn.qrnnSequenceGradient_correct
#print axioms Qrnn.qrnnTerminalGradient_output
#print axioms Qrnn.propagated_error_product_counterexample

#print axioms Qrnn.polar_norm_sq
#print axioms Qrnn.polar_norm
#print axioms Qrnn.sampled_polar_norm_sq
#print axioms Qrnn.gaussianScale_secondMoment
#print axioms Qrnn.uniformAmplitudeBound_secondMoment
#print axioms Qrnn.quaternionSecondMoment_components
#print axioms Qrnn.quaternionVariance_eq
#print axioms Qrnn.quaternionVariance_of_centered
#print axioms Qrnn.quaternionNorm_mean_pos
#print axioms Qrnn.quaternionNorm_variance_lt_secondMoment
#print axioms Qrnn.polar_secondMoment
#print axioms Qrnn.gaussianQuaternion_secondMoment
#print axioms Qrnn.gaussianQuaternion_variance
#print axioms Qrnn.gaussianQuaternion_sigma_secondMoment
#print axioms Qrnn.uniformAmplitudeLaw_isProbability
#print axioms Qrnn.uniformAmplitude_mean
#print axioms Qrnn.uniformAmplitude_secondMoment
#print axioms Qrnn.uniformAmplitude_abs_mean
#print axioms Qrnn.uniformAmplitude_memLp
#print axioms Qrnn.imaginarySample_nonzero_ae
#print axioms Qrnn.uniformPolar_secondMoment
#print axioms Qrnn.uniformPolar_norm_mean
#print axioms Qrnn.uniformPolar_norm_variance
#print axioms Qrnn.uniformPolar_quaternionVariance
#print axioms Qrnn.uniformPolar_moment_ne_gaussian
#print axioms Qrnn.uniformPolar_paperScale_secondMoment
#print axioms Qrnn.correctedUniformPolar_secondMoment
#print axioms Qrnn.zero_direction_polar_counterexample
#print axioms Qrnn.sampledDirection_imI_nonnegative
