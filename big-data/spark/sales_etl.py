import sys

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, expr, trim, when


def normalize_column_name(name: str) -> str:
    return name.strip().lower().replace(" ", "_").replace("(", "").replace(")", "")


def main():
    spark = SparkSession.builder.appName("imdb-movie-etl").getOrCreate()

    input_path = sys.argv[1] if len(sys.argv) > 1 else "s3://your-raw-bucket/"
    output_path = sys.argv[2] if len(sys.argv) > 2 else "s3://your-curated-bucket/"

    df = spark.read.option("header", True).option("inferSchema", True).option("quote", '"').option("escape", '"').csv(input_path)

    for col_name in df.columns:
        df = df.withColumnRenamed(col_name, normalize_column_name(col_name))

    df = df.withColumn("rank", col("rank").cast("int"))
    df = df.withColumn("year", col("year").cast("int"))
    df = df.withColumn("runtime_minutes", col("runtime_minutes").cast("int"))
    df = df.withColumn("rating", col("rating").cast("double"))
    df = df.withColumn("votes", expr("int(regexp_replace(votes, ',', ''))"))
    df = df.withColumn("revenue_millions", col("revenue_millions").cast("double"))
    df = df.withColumn("metascore", col("metascore").cast("int"))

    df = df.withColumn("title", trim(col("title")))
    df = df.withColumn("director", trim(col("director")))
    df = df.withColumn("description", trim(col("description")))

    df = df.withColumn("genres", expr("transform(split(genre, ','), x -> trim(x))"))
    df = df.withColumn("actors", expr("transform(split(actors, ','), x -> trim(x))"))

    df = df.withColumn("release_decade", when(col("year").isNotNull(), (col("year") / 10).cast("int") * 10).otherwise(None))
    df = df.withColumn("is_highly_rated", when(col("rating") >= 8.0, True).otherwise(False))
    df = df.withColumn("has_revenue", when(col("revenue_millions").isNotNull(), True).otherwise(False))

    df = df.dropDuplicates(["title", "year"])
    df = df.na.drop(subset=["title", "year", "rating", "votes"])

    df.write.mode("overwrite").parquet(output_path)
    spark.stop()


if __name__ == "__main__":
    main()
