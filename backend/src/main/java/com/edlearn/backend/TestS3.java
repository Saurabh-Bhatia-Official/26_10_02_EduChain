package com.edlearn.backend;

import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.S3Configuration;
import software.amazon.awssdk.services.s3.model.*;

import java.net.URI;

public class TestS3 {
    public static void main(String[] args) {
        String endpoint = System.getenv("AWS_ENDPOINT_URL_S3");
        String accessKey = System.getenv("AWS_ACCESS_KEY_ID");
        String secretKey = System.getenv("AWS_SECRET_ACCESS_KEY");
        String region = "ap-southeast-1";

        try {
            AwsBasicCredentials creds = AwsBasicCredentials.create(accessKey, secretKey);
            S3Client client = S3Client.builder()
                    .endpointOverride(URI.create(endpoint))
                    .region(Region.of(region))
                    .credentialsProvider(StaticCredentialsProvider.create(creds))
                    .serviceConfiguration(S3Configuration.builder().pathStyleAccessEnabled(true).build())
                    .build();

            System.out.println("Testing S3 connection to: " + endpoint);
            ListBucketsResponse buckets = client.listBuckets();
            System.out.println(">>> S3 SUCCESS! <<<");
            System.out.println("Bucket count: " + buckets.buckets().size());
            for (Bucket b : buckets.buckets()) {
                System.out.println("Bucket: " + b.name());
            }
        } catch (Exception e) {
            System.out.println("S3 test result: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
