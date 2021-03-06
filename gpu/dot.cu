#include "utils/common.h"
#include "types/matrix.h"

template<typename T>
__global__ void mm(T* a, T* b, T* c, T width) {

    int x = blockIdx.x; // block id
    int y = threadIdx.x; // thread id
    T temp = 0;
    for(int i = 0;i< width;i++) {
        temp += a[x*width + i]*b[i*width+ y];
    }

    c[x*width + y] = temp;
}

template<typename T>
void dotGPU(vector<T> &res, const Matrix<T> *lhs, const Matrix<T> &rhs, int start, int startRes) {

    int row1 = lhs->shape[lhs->shape.size()-2];
    int col1 = lhs->shape[lhs->shape.size()-1];
    int row2 = rhs.shape[rhs.shape.size()-2];
    int col2 = rhs.shape[rhs.shape.size()-1];
    
    // Sanity Check
    assert(col1 == row2);

    // Copy to CUDA memory

    T* h_A = lhs->val.data();
    T* h_B = rhs.val.data();
    T* h_C = res.data();

    T *d_a, *d_b, *d_c;
    
    cudaMalloc((void**)&d_a, sizeof(T)*row1*col1);
    cudaMalloc((void**)&d_b, sizeof(T)*row2*col2);
    cudaMalloc((void**)&d_c, sizeof(T)*row1*col2);

    cudaMemcpy((void *)d_a, h_A + start, sizeof(T)*row1*col1, cudaMemcpyHostToDevice);
    cudaMemcpy((void *)d_b, h_B, sizeof(T)*row2*col2, cudaMemcpyHostToDevice);

    mm<T><<<row1,col2>>>(d_a,d_b,d_c,col1);

    // Copy back from cuda memory
    cudaMemcpy(h_C+startRes, (void **)d_c, sizeof(T)*row1*col2, cudaMemcpyDeviceToHost);
}
