{% assign image_files = site.static_files | where: "image", true %}

<ul class="photo-gallery">
  {% for myimage in image_files %}
    <li>
    <figure>
      <img class="{{ myimage.path }}" src="{{ myimage.path }}" alt="Alt: {{ myimage.path }}">
      <figcaption>{{ myimage.path }}</figcaption>
    </figure>
    </li>
  {% endfor %}
</ul>

