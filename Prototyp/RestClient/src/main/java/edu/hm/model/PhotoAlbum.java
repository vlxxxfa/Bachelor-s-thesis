package edu.hm.model;

import java.util.List;

/**
 * Created by vlfa on 15.03.17.
 */
// @Entity(value="photoAlbum")
public class PhotoAlbum {

    private String albumTitle;

    private List<Photo> photoList;

    public String getAlbumTitle() {
        return albumTitle;
    }

    public List<Photo> getPhotoList() {
        return photoList;
    }

    public void setAlbumTitle(String albumTitle) {

        this.albumTitle = albumTitle;
    }

    public void setPhotoList(List<Photo> photoList) {
        this.photoList = photoList;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        PhotoAlbum that = (PhotoAlbum) o;
        if(!this.albumTitle.equals(that.getAlbumTitle())){
            return false;
        }
        return albumTitle.equals(that.albumTitle);
    }

    @Override
    public int hashCode() {
        return albumTitle.hashCode();
    }
}