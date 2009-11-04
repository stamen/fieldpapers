import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileOutputStream;

import javax.imageio.ImageIO;

import com.google.zxing.*;
import com.google.zxing.Reader;
import com.google.zxing.client.j2se.BufferedImageMonochromeBitmapSource;

public class qrdecode
{
    public static void main (String args[]) throws Exception
    {
        File tmpfile = File.createTempFile("qrcode", ".bin");
        FileOutputStream fw = new FileOutputStream(tmpfile);
        
        while (System.in.available() > 0)
        {
            byte[] b = new byte[System.in.available()];
            System.in.read(b, 0, System.in.available());
            fw.write(b);
        }
        
        fw.close();
        tmpfile.deleteOnExit();

        Reader barcodeReader = new MultiFormatReader();
        BufferedImage image = ImageIO.read(tmpfile);
        MonochromeBitmapSource source = new BufferedImageMonochromeBitmapSource(image);
        
        try
        {
            Result result = barcodeReader.decode(source);           
            System.out.println(result.getText());
            System.exit(0);
        }
        
        catch (Exception e)
        {
            System.out.println(e.toString());
            System.exit(1);
        }
    }
}
