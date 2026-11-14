package com.edlearn.backend.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.S3Configuration;

import java.net.URI;

@Configuration
public class S3Config {

    private static final Logger log = LoggerFactory.getLogger(S3Config.class);

    @Value("${aws.s3.endpoint:https://br-restless-shape-b3qhppdx.storage.c-4.ap-southeast-1.aws.neon.tech}")
    private String endpoint;

    @Value("${aws.s3.access-key:nak_live_e304bc80162e4afea37a338a9738015f}")
    private String accessKey;

    @Value("${aws.s3.secret-key:nsk_live_08ba5bee3b3499bddbe28af5b28ee2e5a48bf9cefd95c54e0e70080fdf42424c}")
    private String secretKey;

    @Value("${aws.s3.region:ap-southeast-1}")
    private String region;

    @Bean
    public S3Client s3Client() {
        try {
            AwsBasicCredentials credentials = AwsBasicCredentials.create(accessKey.trim(), secretKey.trim());
            return S3Client.builder()
                    .endpointOverride(URI.create(endpoint.trim()))
                    .region(Region.of(region.trim()))
                    .credentialsProvider(StaticCredentialsProvider.create(credentials))
                    .serviceConfiguration(S3Configuration.builder()
                            .pathStyleAccessEnabled(true)
                            .build())
                    .build();
        } catch (Throwable t) {
            log.info("S3 client not initialized (using Cloudinary as primary): {}", t.getMessage());
            return null;
        }
    }
}
