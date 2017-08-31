class ArrayInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    template.text_area_tag("#{@builder.object_name}[#{attribute_name}][]", @builder.template.assigns['outgoing_message'].try(:to).try(:at, 0))
  end
end
