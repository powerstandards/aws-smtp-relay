package com.loopingz;

import java.io.IOException;
import java.io.InputStream;
import java.lang.invoke.MethodHandles;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;

import org.apache.commons.io.IOUtils;

import com.amazonaws.services.simpleemail.AmazonSimpleEmailService;
import com.amazonaws.services.simpleemail.AmazonSimpleEmailServiceClientBuilder;
import com.amazonaws.services.simpleemail.model.AmazonSimpleEmailServiceException;
import com.amazonaws.services.simpleemail.model.RawMessage;
import com.amazonaws.services.simpleemail.model.SendRawEmailRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SesSmtpRelay extends SmtpRelay {

  private static final Logger LOG = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());

  SesSmtpRelay(DeliveryDetails deliveryDetails) {
    super(deliveryDetails);
  }

  @Override
  public void deliver(String from, String to, InputStream inputStream) throws IOException {
    LOG.info("deliver from {} to {}", from, to);
    AmazonSimpleEmailService client;
    if (deliveryDetails.hasRegion()) {
      client = AmazonSimpleEmailServiceClientBuilder.standard().withRegion(deliveryDetails.getRegion()).build();
    } else {
      client = AmazonSimpleEmailServiceClientBuilder.standard().build();
    }
    byte[] msg = IOUtils.toByteArray(inputStream);
    RawMessage rawMessage = new RawMessage(ByteBuffer.wrap(msg));

    String parsedStr = new String(msg, StandardCharsets.UTF_8).replaceAll("(.{100})", "$1\n");
    LOG.info("Raw Message: {}", parsedStr);
    SendRawEmailRequest rawEmailRequest = new SendRawEmailRequest(rawMessage).withSource(from).withDestinations(to);
    if (deliveryDetails.hasSourceArn()) {
      LOG.info("source ARN: {}", deliveryDetails.getSourceArn());
      rawEmailRequest = rawEmailRequest.withSourceArn(deliveryDetails.getSourceArn());
    }
    if (deliveryDetails.hasFromArn()) {
      LOG.info("From ARN: {}", deliveryDetails.getFromArn());
      rawEmailRequest = rawEmailRequest.withFromArn(deliveryDetails.getFromArn());
    }
    if (deliveryDetails.hasReturnPathArn()) {
      LOG.info("Return Path ARN: {}", deliveryDetails.getReturnPathArn());
      rawEmailRequest = rawEmailRequest.withReturnPathArn(deliveryDetails.getReturnPathArn());
    }
    if (deliveryDetails.hasConfiguration()) {
      LOG.info("configurations: {}", deliveryDetails.getConfiguration());
      rawEmailRequest = rawEmailRequest.withConfigurationSetName(deliveryDetails.getConfiguration());
    }
    try {
      LOG.info("raw email object: {}", rawEmailRequest.toString());
      client.sendRawEmail(rawEmailRequest);
    } catch (AmazonSimpleEmailServiceException e) {
      throw new IOException(e.getMessage(), e);
    }
  }
}
