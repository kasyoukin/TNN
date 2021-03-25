// Tencent is pleased to support the open source community by making TNN available.
//
// Copyright (C) 2020 THL A29 Limited, a Tencent company. All rights reserved.
//
// Licensed under the BSD 3-Clause License (the "License"); you may not use this file except
// in compliance with the License. You may obtain a copy of the License at
//
// https://opensource.org/licenses/BSD-3-Clause
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

#include "tnn/device/metal/acc/metal_unary_layer_acc.h"
#include "tnn/device/metal/acc/metal_common.h"
#include "tnn/device/metal/metal_context.h"
#include "tnn/utils/data_format_converter.h"
#include "tnn/utils/data_type_utils.h"
#include "tnn/utils/half_utils_inner.h"

namespace TNN_NS {

MetalUnaryLayerAcc::~MetalUnaryLayerAcc() {}

Status MetalUnaryLayerAcc::AllocateBufferParam(const std::vector<Blob *> &inputs,
                                               const std::vector<Blob *> &outputs) {
   id<MTLDevice> device = [TNNMetalDeviceImpl sharedDevice];
    auto dims_input      = inputs[0]->GetBlobDesc().dims;
    auto dims_output     = outputs[0]->GetBlobDesc().dims;
    // buffer_param_
    {
        auto metal_params = GetDefaultMetalParams(dims_input, dims_output);
        FixDefaultMetalParams(metal_params, dims_input, dims_output);     
        buffer_param_     = [device newBufferWithBytes:(const void *)(&metal_params)
                                            length:sizeof(metal_params)
                                           options:MTLResourceCPUCacheModeWriteCombined];
    }
    return TNN_OK;
}

std::string MetalUnaryLayerAcc::KernelName(const std::vector<Blob *> &inputs, const std::vector<Blob *> &outputs) {
    return "";
}

Status MetalUnaryLayerAcc::SetKernelEncoderParam(
                                                 id<MTLComputeCommandEncoder> encoder,
                                            const std::vector<Blob *> &inputs,
                                            const std::vector<Blob *> &outputs) {
    return MetalLayerAcc::SetKernelEncoderParam(encoder, inputs, outputs);
}

Status MetalUnaryLayerAcc::ComputeThreadSize(const std::vector<Blob *> &inputs,
                                        const std::vector<Blob *> &outputs,
                                        MTLSize &size) {
    const auto& output_dims = outputs[0]->GetBlobDesc().dims;
    auto hw = GetBlobCount(output_dims, 2);
    auto slice = UP_DIV(output_dims[1] ,4);
    auto batch = output_dims[0];
    size = MTLSizeMake(hw, slice, batch);
    return TNN_OK;
    // return MetalLayerAcc::ComputeThreadSize(inputs, outputs, size);
}

Status MetalUnaryLayerAcc::Forward(const std::vector<Blob *> &inputs,
                                   const std::vector<Blob *> &outputs) {
    return MetalLayerAcc::Forward(inputs, outputs);
}

} // namespace TNN_NS
