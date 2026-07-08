import sys

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, to_date, trim, when


def main():
    spark = SparkSession.builder.appName("sales-etl").getOrCreate()

    input_path = sys.argv[1] if len(sys.argv) > 1 else "s3://your-raw-bucket/"
    output_path = sys.argv[2] if len(sys.argv) > 2 else "s3://your-curated-bucket/"

    df = spark.read.option("header", True).option("inferSchema", True).csv(input_path)

    for col_name in df.columns:
        df = df.withColumnRenamed(col_name, col_name.strip().lower().replace(" ", "_"))

    df = df.dropDuplicates(["order_id"])
    df = df.na.drop(subset=["order_id", "order_date", "customer_id", "product_id", "quantity", "price"])

    df = df.withColumn("quantity", col("quantity").cast("int"))
    df = df.withColumn("price", col("price").cast("double"))
    df = df.withColumn("order_date", to_date(col("order_date"), "yyyy-MM-dd"))
    df = df.withColumn("product_id", trim(col("product_id")))
    df = df.withColumn("customer_id", trim(col("customer_id")))
    df = df.withColumn("total_amount", col("quantity") * col("price"))
    df = df.withColumn("order_status", when(col("quantity") > 0, "valid").otherwise("invalid"))

    df.filter((col("quantity") > 0) & (col("price") >= 0)).write.mode("overwrite").parquet(output_path)
    spark.stop()


if __name__ == "__main__":
    main()
