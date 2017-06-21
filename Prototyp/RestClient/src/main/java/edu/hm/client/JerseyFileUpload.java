package edu.hm.client;

/**
 * Created by vlfa on 22.05.17.
 */

import org.glassfish.jersey.media.multipart.MultiPart;
import org.glassfish.jersey.media.multipart.MultiPartFeature;
import org.glassfish.jersey.media.multipart.file.FileDataBodyPart;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.File;
import java.io.IOException;

public class JerseyFileUpload {
    private final static String contentType = "multipart/mixed";

    public static void postFile(String serverURL, File imgFile) {
        MultiPart multiPart = null;
        try {
            Client client = ClientBuilder.newBuilder().
                    register(MultiPartFeature.class).build();
            WebTarget server = client.target(serverURL);
            multiPart = new MultiPart();

            FileDataBodyPart imgBodyPart = new FileDataBodyPart("imgFile", imgFile,
                    MediaType.APPLICATION_OCTET_STREAM_TYPE);
            // Add body part
            multiPart.bodyPart(imgBodyPart);

            Response response = server.request(MediaType.APPLICATION_JSON_TYPE)
                    .post(Entity.entity(multiPart, contentType));
            if (response.getStatus() == 200) {
                String respnse = (String) response.getEntity();
                System.out.println(respnse);
            } else {
                System.out.println("Response is not ok");
            }
        } catch (Exception e) {
            System.out.println("Exception has occured "+ e.getMessage());
        } finally {
            if (null != multiPart) {
                try {
                    multiPart.close();
                } catch (IOException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
        }
    }
}
