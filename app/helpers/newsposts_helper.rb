module NewspostsHelper
  #TODO: fix this
  def news_tag_path(tag)
    # newsposts_path + '?tag=' + tag.id
    news_tag_newsposts_path(tag)
  end
end
