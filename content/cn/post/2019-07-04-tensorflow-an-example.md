---
title: "Tensorflow-完整神经网络样例程序"
author: "王诗翔"
date: "2019-07-04"
lastmod: "2019-07-04"
slug: ""
categories: [ml]
tags: ["machine-learning", "tensorflow"]
---

来源：《Tensorflow实战Google深度学习框架》第二版，第三章

略修改。

总结而言有三个步骤：

1. 定义神经网络的结构和前向传播的输出结果
2. 定义损失函数以及选择反向传播优化的算法
3. 生成会话并在训练集上反复运行反向传播优化算法

```python
import tensorflow as tf 

# 通过 NumPy 生成模拟数据集
from numpy.random import RandomState

# 定义训练数据的 batch 大小
batch_size = 8

# 定义神经网络的参数
w1 = tf.Variable(tf.random_normal([2, 3], stddev=1, seed=1))
w2 = tf.Variable(tf.random_normal([3, 1], stddev=1, seed=1))

# shape 的一个维度使用 None 可以方便使用不同的 batch 大小
# 在训练时需要把数据分成比较小的 batch
# 但在测试时，可以一次性使用全部的数据
# 在数据较小时这样方便测试，但数据很大放入一个 batch 可能会内存溢出
x  = tf.placeholder(tf.float32, shape=(None, 2), name="x-input")
y_ = tf.placeholder(tf.float32, shape=(None, 1), name="y-input")

# 定义神经网络前向传播过程
a = tf.matmul(x, w1)
y = tf.matmul(a, w2)

# 定义损失函数和反向传播算法
y = tf.sigmoid(y)
cross_entropy = -tf.reduce_mean(
    y_ * tf.log(tf.clip_by_value(y, 1e-10, 1.0))
    + (1-y_) * tf.log(tf.clip_by_value(1-y, 1e-10, 1.0))
)
train_step = tf.train.AdamOptimizer(0.001).minimize(cross_entropy)

# 随机生成一个模拟数据集
rdm = RandomState(1)
dataset_size = 128
X = rdm.rand(dataset_size, 2)

# 定义规则来给出样本的标签。这里 x1+x2<1 的样例认为是正样本（如零件合格）
# 而其他为负样本。
# 大部分解决分类问题的神经网络都会采用 0（负样本） 和 1（正样本） 的表示方法
Y = [[int(x1+x2<1)] for (x1, x2) in X]

# 创建一个会话运行 tensorflow
with tf.Session() as sess:
    init_op = tf.global_variables_initializer()
    # 初始化变量
    sess.run(init_op)

    # 训练之前神经网络参数的值
    print(sess.run(w1))
    print(sess.run(w2))

    # 设定训练的次数
    STEPS = 5000
    for i in range(STEPS):
        # 每次选出 batch_size 个样本进行训练
        start = (i * batch_size) % dataset_size
        end = min(start+batch_size, dataset_size)

        # 通过选取的样本训练神经网络并更新参数
        sess.run(train_step, 
                feed_dict={x: X[start:end], y_: Y[start:end]})
        
        if i == 0 or (i+1) % 1000 == 0:
            # 每隔一段时间计算在所有数据上的交叉熵并输出
            total_cross_entropy = sess.run(
                cross_entropy, feed_dict={x: X, y_: Y}
            )
            print("After %d training step(s), cross entropy on all data is %g" % (i if i==0 else i+1, total_cross_entropy))

    # 更新后的神经网络参数值
    print(sess.run(w1))
    print(sess.run(w2))
```

运行结果：

```shell
$ python tf_an_example.py 
WARNING:tensorflow:From /public/anaconda3/envs/tensor/lib/python3.7/site-packages/tensorflow/python/framework/op_def_library.py:263: colocate_with (from tensorflow.python.framework.ops) is deprecated and will be removed in a future version.
Instructions for updating:
Colocations handled automatically by placer.
2019-07-04 14:24:28.939818: I tensorflow/core/platform/profile_utils/cpu_utils.cc:94] CPU Frequency: 1895430000 Hz
2019-07-04 14:24:28.941254: I tensorflow/compiler/xla/service/service.cc:150] XLA service 0x7fa598f260a0 executing computations on platform Host. Devices:
2019-07-04 14:24:28.941301: I tensorflow/compiler/xla/service/service.cc:158]   StreamExecutor device (0): <undefined>, <undefined>
OMP: Info #212: KMP_AFFINITY: decoding x2APIC ids.
OMP: Info #213: KMP_AFFINITY: cpuid leaf 11 not supported - decoding legacy APIC ids.
OMP: Info #149: KMP_AFFINITY: Affinity capable, using global cpuid info
OMP: Info #154: KMP_AFFINITY: Initial OS proc set respected: 0-7
OMP: Info #156: KMP_AFFINITY: 8 available OS procs
OMP: Info #157: KMP_AFFINITY: Uniform topology
OMP: Info #159: KMP_AFFINITY: 2 packages x 4 cores/pkg x 1 threads/core (8 total cores)
OMP: Info #214: KMP_AFFINITY: OS proc to physical thread map:
OMP: Info #171: KMP_AFFINITY: OS proc 0 maps to package 0 core 0 
OMP: Info #171: KMP_AFFINITY: OS proc 1 maps to package 0 core 1 
OMP: Info #171: KMP_AFFINITY: OS proc 2 maps to package 0 core 2 
OMP: Info #171: KMP_AFFINITY: OS proc 3 maps to package 0 core 3 
OMP: Info #171: KMP_AFFINITY: OS proc 4 maps to package 1 core 0 
OMP: Info #171: KMP_AFFINITY: OS proc 5 maps to package 1 core 1 
OMP: Info #171: KMP_AFFINITY: OS proc 6 maps to package 1 core 2 
OMP: Info #171: KMP_AFFINITY: OS proc 7 maps to package 1 core 3 
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7723 thread 0 bound to OS proc set 0
2019-07-04 14:24:28.943084: I tensorflow/core/common_runtime/process_util.cc:71] Creating new thread pool with default inter op setting: 2. Tune using inter_op_parallelism_threads for best performance.
[[-0.8113182   1.4845988   0.06532937]
 [-2.4427042   0.0992484   0.5912243 ]]
[[-0.8113182 ]
 [ 1.4845988 ]
 [ 0.06532937]]
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7766 thread 1 bound to OS proc set 4
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7787 thread 2 bound to OS proc set 1
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7788 thread 3 bound to OS proc set 5
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7790 thread 5 bound to OS proc set 6
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7789 thread 4 bound to OS proc set 2
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7792 thread 6 bound to OS proc set 3
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7795 thread 7 bound to OS proc set 7
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7797 thread 8 bound to OS proc set 0
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7767 thread 9 bound to OS proc set 4
After 0 training step(s), cross entropy on all data is 1.89805
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7809 thread 10 bound to OS proc set 1
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7812 thread 11 bound to OS proc set 5
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7813 thread 12 bound to OS proc set 2
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7814 thread 13 bound to OS proc set 6
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7817 thread 15 bound to OS proc set 7
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7816 thread 14 bound to OS proc set 3
OMP: Info #250: KMP_AFFINITY: pid 7723 tid 7818 thread 16 bound to OS proc set 0
After 1000 training step(s), cross entropy on all data is 0.655198
After 2000 training step(s), cross entropy on all data is 0.626185
After 3000 training step(s), cross entropy on all data is 0.615106
After 4000 training step(s), cross entropy on all data is 0.610311
After 5000 training step(s), cross entropy on all data is 0.608681
[[ 0.02476973  0.56948674  1.6921943 ]
 [-2.1977348  -0.23668918  1.1143894 ]]
[[-0.4554469 ]
 [ 0.49110925]
 [-0.9811033 ]]
```

还行吧，先照虎画猫。
