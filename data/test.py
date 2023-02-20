import tensorflow as tf

with open("/data/test_out.txt", "w") as out:
  out.write("GPUs: "+str(tf.config.list_physical_devices('GPU'))+"\n\n")
  out.write("Reduce sum: "+str(tf.reduce_sum(tf.random.normal([1000, 1000])))+"\n")

