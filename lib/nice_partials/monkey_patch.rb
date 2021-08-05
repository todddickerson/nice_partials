# Monkey patch required to make `t` work as expected. Is this evil?
# TODO Do we need to monkey patch other types of renderers as well?
class ActionView::PartialRenderer
  alias_method :original_render, :render

  # See `content_for` in `lib/nice_partials/partial.rb` for something similar.
  def render(partial, context, block)
    if block
      partial_prefix = nice_partials_locale_prefix_from_view_context_and_block(context, block)
      context.nice_partials_push_t_prefix partial_prefix
    else
      # Render partial calls with no block should disable any prefix magic.
      context.nice_partials_push_t_prefix ''
    end

    result = original_render(partial, context, block)

    # Whether there was a block or not, pop off whatever we put on the stack.
    context.nice_partials_pop_t_prefix

    return result
  end
end

class ActionView::Renderer
  alias_method :original_render, :render

  # See `content_for` in `lib/nice_partials/partial.rb` for something similar.
  def render(context, options, block)
    if block
      partial_prefix = nice_partials_locale_prefix_from_view_context_and_block(context, block)
      context.nice_partials_push_t_prefix partial_prefix
    else
      # Render partial calls with no block should disable any prefix magic.
      context.nice_partials_push_t_prefix ''
    end

    result = original_render(context, options, block)

    # Whether there was a block or not, pop off whatever we put on the stack.
    context.nice_partials_pop_t_prefix

    return result
  end
end
