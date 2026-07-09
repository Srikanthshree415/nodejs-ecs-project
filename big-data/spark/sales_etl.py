import sys
from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col,
    expr,
    trim,
    when,
    regexp_replace,
    current_date,
    current_timestamp
)


def normalize_column_name(name: str) -> str:
    return (
        name.strip()
        .lower()
        .replace(" ", "_")
        .replace("(", "")
        .replace(")", "")
    )


def main():
    spark = SparkSession.builder.appName("imdb-movie-etl").getOrCreate()

    input_path = (
        sys.argv[1]
        if len(sys.argv) > 1
        else "s3://your-raw-bucket/"
    )

output_path = (
    sys.argv[2]
    if len(sys.argv) > 2
    else "s3://your-processed-bucket/output/"
)

    print("=" * 60)
    print("Input Path :", input_path)
    print("Output Path:", output_path)
    print("=" * 60)

    df = (
        spark.read
        .option("header", True)
        .option("inferSchema", True)
        .option("quote", '"')
        .option("escape", '"')
        .csv(input_path)
    )

    print("\n===== RAW SCHEMA =====")
    df.printSchema()

    print("\n===== RAW RECORD COUNT =====")
    print(df.count())

    for col_name in df.columns:
        df = df.withColumnRenamed(col_name, normalize_column_name(col_name))

    df = df.withColumn("rank", col("rank").cast("int"))
    df = df.withColumn("year", col("year").cast("int"))
    df = df.withColumn("runtime_minutes", col("runtime_minutes").cast("int"))
    df = df.withColumn("rating", col("rating").cast("double"))
    df = df.withColumn("votes", regexp_replace(col("votes"), ",", "").cast("int"))
    df = df.withColumn("revenue_millions", col("revenue_millions").cast("double"))
    df = df.withColumn("metascore", col("metascore").cast("int"))

    df = df.withColumn("title", trim(col("title")))
    df = df.withColumn("director", trim(col("director")))
    df = df.withColumn("description", trim(col("description")))

    df = df.withColumn(
        "genres",
        expr("transform(split(genre, ','), x -> trim(x))")
    )

    df = df.withColumn(
        "actors",
        expr("transform(split(actors, ','), x -> trim(x))")
    )

    df = df.withColumn(
        "release_decade",
        when(
            col("year").isNotNull(),
            (col("year") / 10).cast("int") * 10
        ).otherwise(None)
    )

    df = df.withColumn(
        "is_highly_rated",
        when(col("rating") >= 8.0, True).otherwise(False)
    )

    df = df.withColumn(
        "has_revenue",
        when(col("revenue_millions").isNotNull(), True).otherwise(False)
    )

    df = df.dropDuplicates(["title", "year"])
    df = df.na.drop(subset=["title", "year", "rating", "votes"])

    # Audit columns
    df = df.withColumn("load_date", current_date())
    df = df.withColumn("load_timestamp", current_timestamp())

    df = df.cache()

    print("\n===== TRANSFORMED SCHEMA =====")
    df.printSchema()

    print("\n===== SAMPLE DATA =====")
    df.show(10, truncate=False)

    print("\n===== FINAL RECORD COUNT =====")
    print(df.count())

    print("\n===== WRITING PARQUET FILES =====")

   (
    df.write
    .mode("overwrite")
    .partitionBy("load_date")
    .option("compression", "snappy")
    .parquet(output_path)
)
    print("===== PARQUET WRITE COMPLETED SUCCESSFULLY =====")

    spark.stop()


if __name__ == "__main__":
    main()