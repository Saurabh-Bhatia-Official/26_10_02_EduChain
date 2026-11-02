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
        String endpoint = "https://br-restless-shape-b3qhppdx.storage.c-4.ap-southeast-1.aws.neon.tech";
        String accessKey = "nak_live_e304bc80162e4afea37a338a9738015f";
        String secretKey = "nsk_live_08ba5bee3b3499bddbe28af5b28ee2e5a48bf9cefd95c54e0e70080fdf42424c";
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
