{% assign image_files = site.static_files | where: "image", true %}

{::comment}

site.static_files: {{ site.static_files }}

image_files: {{ image_files }}

{:/comment}

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

