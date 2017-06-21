package edu.hm.model;

import org.springframework.web.multipart.MultipartFile;

/**
 * Created by vlfa on 15.03.17.
 */
// @Entity(value="photo")
public class Photo {

    private String id;

    private String title;

    private String base64;

    private MultipartFile multipartFile;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getBase64() {
        return base64;
    }

    public void setBase64(String base64) {
        this.base64 = base64;
    }

    public MultipartFile getMultipartFile() {
        return multipartFile;
    }

    public void setMultipartFile(MultipartFile multipartFile) {
        this.multipartFile = multipartFile;
    }

    @Override
    public String toString() {
        return "Photo{" +
                "title='" + multipartFile.getName() + '\'' +
                ", multipartFile=" + multipartFile +
                '}';
    }
}


