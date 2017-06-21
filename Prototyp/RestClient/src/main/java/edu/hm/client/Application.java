package edu.hm.client;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;
import edu.hm.model.PhotoAlbum;
import edu.hm.model.User;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * Created by vlfa on 20.05.17.
 */
public class Application {

    // private String baseUrl = "http://52.58.78.193:8080/users/"; // BackendOne
    private String baseUrl = "http://52.57.69.149:8080/users/";  // BackendTwo
    private WebResource webResource;

    private void findAllAccounts(){

        try {
            webResource = getClient().resource(baseUrl + "findAllUsers");

            ClientResponse response = webResource.accept("application/json").get(ClientResponse.class);

            if (response.getStatus() != 200) {
                throw new RuntimeException("Failed : HTTP error code : " + response.getStatus());
            }

            String output = response.getEntity(String.class);
            System.out.println(output);
        }
        catch (Exception e){
            e.printStackTrace();
        }
    }

    private void createAccount(User user){
        // data binding to convert Java object to JSON
        ObjectMapper mapper = new ObjectMapper();

        try {
            //Object to JSON in String
            String jsonInString = mapper.writeValueAsString(user);
            webResource = getClient().resource(baseUrl + "createUser");
            ClientResponse response = webResource.type("application/json").post(ClientResponse.class, jsonInString);

            if (response.getStatus() != 200) {
                throw new RuntimeException("Failed : HTTP error code : " + response.getStatus());
            }
        }
        catch (Exception e){
            e.printStackTrace();
        }
    }

    private void createPhotoAlbumByUserName(String userName, PhotoAlbum photoAlbum){
        // data binding to convert Java object to JSON
        ObjectMapper mapper = new ObjectMapper();

        try {
            //Object to JSON in String
            String jsonInString = mapper.writeValueAsString(photoAlbum);
            webResource = getClient().resource(baseUrl + userName + "/photoAlben/createPhotoAlbumByUserName");
            ClientResponse response = webResource.type("application/json").post(ClientResponse.class, jsonInString);

            if (response.getStatus() != 200) {
                throw new RuntimeException("Failed : HTTP error code : " + response.getStatus());
            }
        }
        catch (Exception e){
            e.printStackTrace();
        }
    }

    private void savePhotoByAlbumTitleOfUser(String userName, String albumTitle, File imgFile) {
        String url = baseUrl + userName + "/" + albumTitle + "/photos/savePhotoByAlbumTitleOfUser/";

        HttpClient httpclient = new DefaultHttpClient();
        HttpPost httppost = new HttpPost(url);
        FileBody fileContent= new FileBody(imgFile);
        // StringBody comment = new StringBody("Filename: " + imgFile.);
        MultipartEntity reqEntity = new MultipartEntity();
        reqEntity.addPart("file", fileContent);
        httppost.setEntity(reqEntity);
        HttpResponse response = null;
        try {
            response = httpclient.execute(httppost);
        } catch (IOException e) {
            e.printStackTrace();
        }
        HttpEntity resEntity = response.getEntity();
    }

    private Client getClient(){
        return Client.create();
    }

    private int getRandomInt(){
        Random random = new Random();
        return random.nextInt(100000 + 1000 - 1000) + 1000;
    }

    String generateRandomWord(int wordLength) {
        Random r = new Random(); // Intialize a Random Number Generator with SysTime as the seed
        StringBuilder sb = new StringBuilder(wordLength);
        for(int i = 0; i < wordLength; i++) { // For each letter in the word
            char tmp = (char) ('a' + r.nextInt('z' - 'a')); // Generate a letter between a and z
            sb.append(tmp); // Add it to the String
        }
        return sb.toString();
    }

    public static void main (String[] args){

        Random random = new Random();

        List<File> images = new ArrayList<File>();
        images.add(new File("/Users/vlfa/Dropbox/Development/PhotographicAlbumManagement/pam-presentation/src/main/resources/img/Schmetterling.jpeg"));
        images.add(new File("/Users/vlfa/Dropbox/Development/PhotographicAlbumManagement/pam-presentation/src/main/resources/img/Katze.jpeg"));
        images.add(new File("/Users/vlfa/Dropbox/Development/PhotographicAlbumManagement/pam-presentation/src/main/resources/img/Loewe.jpeg"));
        images.add(new File("/Users/vlfa/Dropbox/Development/PhotographicAlbumManagement/pam-presentation/src/main/resources/img/Vogel.jpeg"));
        images.add(new File("/Users/vlfa/Dropbox/Development/PhotographicAlbumManagement/pam-presentation/src/main/resources/img/A.jpeg"));
        images.add(new File("/Users/vlfa/Dropbox/Development/PhotographicAlbumManagement/pam-presentation/src/main/resources/img/B.jpeg"));
        images.add(new File("/Users/vlfa/Dropbox/Development/PhotographicAlbumManagement/pam-presentation/src/main/resources/img/C.jpeg"));
        images.add(new File("/Users/vlfa/Dropbox/Development/PhotographicAlbumManagement/pam-presentation/src/main/resources/img/D.jpeg"));
        images.add(new File("/Users/vlfa/Dropbox/Development/PhotographicAlbumManagement/pam-presentation/src/main/resources/img/E.jpeg"));
        images.add(new File("/Users/vlfa/Dropbox/Development/PhotographicAlbumManagement/pam-presentation/src/main/resources/img/F.jpeg"));

        Application application = new Application();

        for (int i = 0; i < application.getRandomInt(); i++) {
            User user = new User();
            // user.setUserName("BackendTOne_" + application.generateRandomWord(5) + "_" + i);
            user.setUserName("BackendTwoPart2_" + application.generateRandomWord(5) + "_" + i);
            user.setPassWord(application.generateRandomWord(12));
            user.setEmail(application.generateRandomWord(5) + "@email.de");
            application.createAccount(user);

            // for (int j = 0; j < application.getRandomInt(); j++) {
            for (int j = 0; j < 4; j++) {
                PhotoAlbum photoAlbum = new PhotoAlbum();
                photoAlbum.setAlbumTitle(application.generateRandomWord(5) + "_" + i + "_" + j);
                application.createPhotoAlbumByUserName(user.getUserName(), photoAlbum);

                // for (int k = 0; k < application.getRandomInt(); k++) {
                for (int k = 0; k < 4; k++) {
                    int i1 = random.nextInt(6 + 0 - 0) + 0;
                    File imgFile = images.get(i1);
                    application.savePhotoByAlbumTitleOfUser(user.getUserName(), photoAlbum.getAlbumTitle(), imgFile);
                }
            }
        }
        application.findAllAccounts();
    }

}