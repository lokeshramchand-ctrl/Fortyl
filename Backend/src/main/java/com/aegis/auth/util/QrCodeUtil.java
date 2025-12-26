package com.aegis.auth.util;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.common.BitMatrix;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Base64;

public class QrCodeUtil {

  public static String toBase64Png(String text) {
    try {
      QRCodeWriter writer = new QRCodeWriter();
      BitMatrix matrix = writer.encode(text, BarcodeFormat.QR_CODE, 300, 300);

      BufferedImage image = new BufferedImage(300, 300, BufferedImage.TYPE_INT_RGB);
      for (int x = 0; x < 300; x++) {
        for (int y = 0; y < 300; y++) {
          image.setRGB(x, y, matrix.get(x, y) ? 0xFF000000 : 0xFFFFFFFF);
        }
      }

      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      ImageIO.write(image, "png", baos);

      return Base64.getEncoder().encodeToString(baos.toByteArray());

    } catch (WriterException | IOException e) {
      throw new RuntimeException("Failed to generate QR code", e);
    }
  }
}
