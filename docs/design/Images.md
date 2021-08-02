{::comment}
This doesn't work at GitHub

{{ site.static_files }}

{:/comment}

{% assign image_files = site.static_files | where: "image", true %}

<ul class="photo-gallery">
  {% for myimage in image_files %}
    <li>
    <figure>
      <img src="{{ myimage.path | relative_url }}" alt="{{ myimage.path | relative_url }}">
      <figcaption>{{ myimage.path }}</figcaption>
    </figure>
    </li>
  {% endfor %}
</ul>

