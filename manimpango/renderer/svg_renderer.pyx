import typing as T
from ..layout import Layout

include "cairo_utils.pxi"

cdef class SVGRenderer:
    """:class:`SVGRenderer` is a renderer which renders the
    :class:`~.Layout` to an SVG file.

    The :attr:`file_name` is opened when the class is initialised
    and only closed when the renderer is destroyed.

    Parameters
    ==========
    file_name: :class:`str`
        The path to SVG file.
    width: :class:`float`
        The width of the SVG.
    height: :class:`float`
        The height of the SVG.
    layout: :class:`Layout`
        The :class:`~.Layout` that needs to be rendered.

    Example
    =======
    >>> import manimpango as mp
    >>> a = mp.SVGRenderer('test.svg', 100, 100, mp.Layout('hello'))
    >>> a
    <SVGRenderer file_name='test.svg' width=100.0 height=100.0 layout=<Layout text='hello' markup=None>
    >>> a.render()
    True

    Raises
    ======
    Exception
        Any error reported by cairo.
    """
    def __cinit__(
        self,
        file_name: str,
        width: float,
        height: float,
        layout: Layout
    ):
        surface = cairo_svg_surface_create(
            file_name.encode("utf-8"),
            width,
            height
        )
        if surface == NULL:
            raise MemoryError("Cairo.SVGSurface can't be created.")
        self.cairo_surface = surface
        self.cairo_context = create_cairo_context_from_surface(surface)
        self.pango_layout = create_pango_layout(self.cairo_context)
        self.pango_font_desc = create_font_desc()

    def __init__(
        self,
        file_name: str,
        width: float,
        height: float,
        layout: Layout
    ):
        self._file_name = file_name
        self._width = width
        self._height = height
        self.py_layout = layout
        self.py_font_desc = layout.font_desc

    cdef bint start_renderering(self):
        pylayout_to_pango_layout(self.pango_layout, self.py_layout)
        pyfontdesc_to_pango_font_desc(self.pango_font_desc, self.py_font_desc)
        pango_layout_set_font_description(
            self.pango_layout,
            self.pango_font_desc
        )
        # Check if the context is fine
        _err = is_context_fine(self.cairo_context)
        if _err != "":
            raise Exception(_err)

        # Assign the font description to the layout
        pango_layout_set_font_description(self.pango_layout,
            self.pango_font_desc)

        # Render the actual layout into the cairo context
        pango_cairo_show_layout(self.cairo_context,
            self.pango_layout)

        # Check if the context is fine again
        _err = is_context_fine(self.cairo_context)
        if _err != "":
            raise Exception(_err)
        return 1

    cpdef bint render(self):
        """:meth:`render` actually does the rendering.
        Any error reported by Cairo is reported as an exception.
        If this method suceeds you can expect an valid SVG file at
        :attr:`file_name`.

        Returns
        =======
        bool
            ``True`` if the function worked, else ``False``.
        """
        return self.start_renderering()

    def __repr__(self) -> str:
        return (f"<SVGRenderer file_name={repr(self.file_name)}"
            f" width={repr(self.width)}"
            f" height={repr(self.height)}"
            f" layout={repr(self.layout)}")

    def __dealloc__(self):
        if self.pango_layout:
            g_object_unref(self.pango_layout)
        if self.cairo_context:
            cairo_destroy(self.cairo_context)
        if self.cairo_surface:
            cairo_surface_destroy(self.cairo_surface)
        if self.pango_font_desc:
            pango_font_description_free(self.pango_font_desc)

    @property
    def file_name(self) -> str:
        """The file_name where the file is rendered onto"""
        return self._file_name

    @property
    def width(self) -> float:
        """The width of the SVG."""
        return self._width

    @property
    def height(self) -> float:
        """The height of the SVG."""
        return self._height

    @property
    def layout(self) -> Layout:
        """The :class:`~.Layout` which is being rendered.
        """
        return self.py_layout