package edu.hm.model;

import java.util.List;

/**
 * Created by vlfa on 15.03.17.
 */
// @Entity(value="user")
public class User {

    private String userName;

    private String passWord;

    private String email;

    private List<PhotoAlbum> photoAlbumList;

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public void setPassWord(String passWord) {
        this.passWord = passWord;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPhotoAlbumList(List<PhotoAlbum> photoAlbumList) {
        this.photoAlbumList = photoAlbumList;
    }

    public String getUserName() {

        return userName;
    }

    public String getPassWord() {
        return passWord;
    }

    public String getEmail() {
        return email;
    }

    public List<PhotoAlbum> getPhotoAlbumList() {
        return photoAlbumList;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        User user = (User) o;

        if (!userName.equals(user.userName)) return false;
        return passWord.equals(user.passWord);
    }

    @Override
    public int hashCode() {
        int result = userName.hashCode();
        result = 31 * result + passWord.hashCode();
        return result;
    }

    @Override
    public String toString() {
        return "User{" +
                "userName='" + userName + '\'' +
                ", passWord='" + passWord + '\'' +
                ", email='" + email + '\'' +
                '}';
    }
}