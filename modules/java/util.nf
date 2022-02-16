import java.nio.file.Paths

def getCsvBucketPath ( filePath  ) {
    objPath = java.nio.file.Paths.get("/data/inputs/s3")

    try {
        csvPath = objPath.relativize(java.nio.file.Paths.get(filePath))
        bucket = csvPath.getName(0)
        path = bucket.relativize(csvPath)
        return [ bucket, path ]

    } catch (Exception e) {
        println("Path to CSV with --catsup does not exists on this system and couldn't find a potential bucket path. Quitting.")
        println(e)
        System.exit(1)
    }
}