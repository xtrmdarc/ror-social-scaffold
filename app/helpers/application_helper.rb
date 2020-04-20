module ApplicationHelper
  def menu_link_to(link_text, link_path)
    class_name = current_page?(link_path) ? 'menu-item active' : 'menu-item'

    content_tag(:div, class: class_name) do
      link_to link_text, link_path
    end
  end

  def like_or_dislike_btn(post)
    like = Like.find_by(post: post, user: current_user)
    if like
      link_to('Dislike!', post_like_path(id: like.id, post_id: post.id), method: :delete)
    else
      link_to('Like!', post_likes_path(post_id: post.id), method: :post)
    end
  end

  def like_or_dislike_heart(post)
    like = Like.find_by(post: post, user: current_user)
    if like
      "<a href='#{post_like_path(id: like.id, post_id: post.id)}' data-method='delete' rel='nofollow' >
        #{image_tag 'heart-filled.png', size: 15, class: 'filled heart'}
      </a>".html_safe
    else
      "<a href='#{post_likes_path(post_id: post.id)}' data-method='post' rel='nofollow'>
        #{image_tag 'heart.png', size: 15, class: 'heart'}
      </a>".html_safe
    end
  end
end
