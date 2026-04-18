#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "base64"
require "pathname"

require_relative "./lib/shed_kv"

module ArtPanel
  module_function

  IMAGE_EXTENSIONS = %w[
    .jpg
    .jpeg
    .png
    .webp
    .gif
    .avif
  ].freeze

  CURRENT_IMAGE_KEY = "art_panel.current_image"

  def images_dir
    File.expand_path("../widgets/images/portrait", __dir__)
  end

  def all_images
    return [] unless Dir.exist?(images_dir)

    Dir.glob(File.join(images_dir, "**", "*"))
       .select { |path| File.file?(path) && image_file?(path) }
       .map { |path| Pathname.new(path).relative_path_from(Pathname.new(images_dir)).to_s }
       .sort
  end

  def image_file?(path)
    IMAGE_EXTENSIONS.include?(File.extname(path).downcase)
  end

  def current_image
    value = get_kv(CURRENT_IMAGE_KEY)
    return nil if value.nil? || value.strip.empty?

    filename = value.strip
    all_images.include?(filename) ? filename : nil
  end

  def set_current_image(filename)
    set_kv(CURRENT_IMAGE_KEY, filename)
  end

  def pick_random_image(excluding: nil)
    images = all_images
    return nil if images.empty?

    candidates =
      if excluding && images.length > 1
        images.reject { |name| name == excluding }
      else
        images
      end

    candidates.sample
  end

  def ensure_current_image!
    filename = current_image || pick_random_image
    set_current_image(filename) if filename
    filename
  end

  def next_image!
    current = current_image
    filename = pick_random_image(excluding: current)
    set_current_image(filename) if filename
    filename
  end

  def absolute_image_path(relative_path)
    File.join(images_dir, relative_path)
  end

  def mime_type_for(filename)
    case File.extname(filename).downcase
    when ".jpg", ".jpeg" then "image/jpeg"
    when ".png"          then "image/png"
    when ".webp"         then "image/webp"
    when ".gif"          then "image/gif"
    when ".avif"         then "image/avif"
    else "application/octet-stream"
    end
  end

  def data_url_for(relative_path)
    path = absolute_image_path(relative_path)
    mime = mime_type_for(relative_path)
    encoded = Base64.strict_encode64(File.binread(path))
    "data:#{mime};base64,#{encoded}"
  end

  def payload(filename)
    images = all_images

    if filename.nil?
      return {
        error: "No images found",
        detail: "Add portrait images to widgets/images"
      }
    end

    {
      filename: filename,
      image_src: data_url_for(filename),
      count: images.length
    }
  end
end

begin
  command = ARGV[0] || "status"

  filename =
    case command
    when "status"
      ArtPanel.ensure_current_image!
    when "next"
      ArtPanel.next_image! || ArtPanel.ensure_current_image!
    else
      nil
    end

  if %w[status next].include?(command)
    puts JSON.generate(ArtPanel.payload(filename))
  else
    puts JSON.generate(error: "Unknown command: #{command}")
  end
rescue StandardError => e
  puts JSON.generate(
    error: "Could not load art panel image",
    detail: e.message
  )
end
