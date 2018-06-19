#; RUN : onnx-as lenet.onnx.s | onnx2tg -march bm1880 -print-machineinstrs | FileCheck lenet.onnx.noctable.s
#; CHECK: <11520 x INT8>({{.*}}) %conv1_1 = Conv <inN:1, inC:1, inH:1c, inW:1c, outC:14, groups:1, kH:5, kW:5, dilationH:1, dilationW:1, padH:0, padW:0, strideH:1, strideW:1, m_DoBias:1, rShiftWidth:0> (<784 x INT8>({{.*}}) %data_0, <500 x INT8>({{.*}}) %conv1_w_0, <20 x INT16>({{.*}}) %conv1_b_0)
#; CHECK: <2880 x INT8>({{.*}}) %pool1_1 = MaxPool <N:1, C:14, H:18, W:18,  kH:2, kW:2, padH:0, padW:0, srideH:2, strideW:2, rShiftWidth:0, thresholdX:0> (<11520 x INT8>({{.*}}) %conv1_1)
#; CHECK: <3200 x INT8>({{.*}}) %conv2_1 = Conv <inN:1, inC:14, inH:c, inW:c, outC:32, groups:1, kH:5, kW:5, dilationH:1, dilationW:1, padH:0, padW:0, strideH:1, strideW:1, m_DoBias:1, rShiftWidth:0> (<2880 x INT8>({{.*}}) %pool1_1, <25000 x INT8>({{.*}}) %conv2_w_0, <50 x INT16>({{.*}}) %conv2_b_0)
#; CHECK: <800 x INT8>({{.*}}) %pool2_1 = MaxPool <N:1, C:32, H:8, W:8,  kH:2, kW:2, padH:0, padW:0, srideH:2, strideW:2, rShiftWidth:0, thresholdX:0> (<3200 x INT8>({{.*}}) %conv2_1)
#; CHECK: <500 x INT8>({{.*}}) %ip1_1 = Gemm <inRowNum:1, inColNum:320, outColNum:1f4, m_weightTp:1, do_activation1, activation_method:0, lShiftWidth:0, rShiftWidth:0> (<800 x INT8>({{.*}}) %OC2_DUMMY_0, <400000 x INT8>({{.*}}) %ip1_w_0, <500 x INT16>({{.*}}) %ip1_b_0)
#; <10 x INT8>({{.*}}) %ip2_1 = Gemm <inRowNum:1, inColNum:1f4, outColNum:a, m_weightTp:1, do_activation50, activation_method:0, lShiftWidth:0, rShiftWidth:0> (<500 x INT8>({{.*}}) %ip1_1, <5000 x INT8>({{.*}}) %ip2_w_0, <10 x INT16>({{.*}}) %ip2_b_0)

ir_version: 3
producer_name: "onnx-caffe2"
producer_version: ""
domain: ""
model_version: 0
doc_string: ""
graph {
  name: "LeNet"
  node { input: "data_0" input: "conv1_w_0" input: "conv1_b_0" output: "conv1_1" name: "" op_type: "Conv" attribute { name: "pads" ints: 0 ints: 0 ints: 0 ints: 0 type: INTS } attribute { name: "strides" ints: 1 ints: 1 type: INTS } attribute { name: "kernel_shape" ints: 5 ints: 5 type: INTS } }
  node { input: "conv1_1" output: "pool1_1" name: "" op_type: "MaxPool" attribute { name: "pads" ints: 0 ints: 0 ints: 1 ints: 1 type: INTS } attribute { name: "kernel_shape" ints: 2 ints: 2 type: INTS } attribute { name: "strides" ints: 2 ints: 2 type: INTS } }
  node { input: "pool1_1" input: "conv2_w_0" input: "conv2_b_0" output: "conv2_1" name: "" op_type: "Conv" attribute { name: "pads" ints: 0 ints: 0 ints: 0 ints: 0 type: INTS } attribute { name: "strides" ints: 1 ints: 1 type: INTS } attribute { name: "kernel_shape" ints: 5 ints: 5 type: INTS } }
  node { input: "conv2_1" output: "pool2_1" name: "" op_type: "MaxPool" attribute { name: "pads" ints: 0 ints: 0 ints: 1 ints: 1 type: INTS } attribute { name: "kernel_shape" ints: 2 ints: 2 type: INTS } attribute { name: "strides" ints: 2 ints: 2 type: INTS } }
  node { input: "pool2_1" input: "OC2_DUMMY_1" output: "OC2_DUMMY_0" op_type: "Reshape" }
  node { input: "OC2_DUMMY_0" input: "ip1_w_0" input: "ip1_b_0" output: "ip1_1" op_type: "Gemm" attribute { name: "transB" i: 1 type: INT } attribute { name: "broadcast" i: 1 type: INT } }
  node { input: "ip1_1" output: "relu1_1" name: "" op_type: "Relu" }
  node { input: "relu1_1" input: "ip2_w_0" input: "ip2_b_0" output: "ip2_1" op_type: "Gemm" attribute { name: "transB" i: 1 type: INT } attribute { name: "broadcast" i: 1 type: INT } }
  node { input: "ip2_1" output: "prob_1" name: "" op_type: "Softmax" }
  initializer { dims: 2 data_type: INT64 name: "OC2_DUMMY_1" raw_data: "\001\000\000\000\000\000\000\000 \003\000\000\000\000\000\000" }
  input { name: "data_0" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 1 } dim { dim_value: 1 } dim { dim_value: 28 } dim { dim_value: 28 } } } } }
  input { name: "conv1_w_0" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 20 } dim { dim_value: 1 } dim { dim_value: 5 } dim { dim_value: 5 } } } } }
  input { name: "conv1_b_0" type { tensor_type { elem_type: INT16 shape { dim { dim_value: 20 } } } } }
  input { name: "conv2_w_0" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 50 } dim { dim_value: 20 } dim { dim_value: 5 } dim { dim_value: 5 } } } } }
  input { name: "conv2_b_0" type { tensor_type { elem_type: INT16 shape { dim { dim_value: 50 } } } } }
  input { name: "ip1_w_0" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 500 } dim { dim_value: 800 } } } } }
  input { name: "ip1_b_0" type { tensor_type { elem_type: INT16 shape { dim { dim_value: 500 } } } } }
  input { name: "ip2_w_0" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 10 } dim { dim_value: 500 } } } } }
  input { name: "ip2_b_0" type { tensor_type { elem_type: INT16 shape { dim { dim_value: 10 } } } } }
  input { name: "OC2_DUMMY_1" type { tensor_type { elem_type: INT64 shape { dim { dim_value: 2 } } } } }
  output { name: "prob_1" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 1 } dim { dim_value: 10 } } } } }
  value_info { name: "conv1_1" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 1 } dim { dim_value: 20 } dim { dim_value: 24 } dim { dim_value: 24 } } } } }
  value_info { name: "pool1_1" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 1 } dim { dim_value: 20 } dim { dim_value: 12 } dim { dim_value: 12 } } } } }
  value_info { name: "conv2_1" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 1 } dim { dim_value: 50 } dim { dim_value: 8 } dim { dim_value: 8 } } } } }
  value_info { name: "pool2_1" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 1 } dim { dim_value: 50 } dim { dim_value: 4 } dim { dim_value: 4 } } } } }
  value_info { name: "OC2_DUMMY_0" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 1 } dim { dim_value: 800 } } } } }
  value_info { name: "ip1_1" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 1 } dim { dim_value: 500 } } } } }
  value_info { name: "relu1_1" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 1 } dim { dim_value: 500 } } } } }
  value_info { name: "ip2_1" type { tensor_type { elem_type: INT8 shape { dim { dim_value: 1 } dim { dim_value: 10 } } } } }
}
opset_import { domain: "" version: 6 }
