{% assign image_files = site.static_files | where: "image", true %}

<ul class="photo-gallery">
  {% for myimage in image_files %}
    <li>
    <figure>
      <img src="{{ site.xbase}}{{ myimage.path }}" alt="{{ site.xbase }}/{{ myimage.path }}">
      <figcaption>{{ site.xbase }}{{ myimage.path }}</figcaption>
    </figure>
    </li>
  {% endfor %}
</ul>

<ul class="photo-gallery">
  {% for myimage in image_files %}
    <li>
    <figure>
      <img src="{{ myimage.path }}" alt="{{ myimage.path }}">
      <figcaption>{{ myimage.path }}</figcaption>
    </figure>
    </li>
  {% endfor %}
</ul>

