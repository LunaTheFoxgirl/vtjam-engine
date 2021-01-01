module engine.ui.surface;
import engine;
import containers.list;
import std.stdio;

/**
    A stack of surfaces
*/
static class SurfaceStack {
private static:
    List!WidgetSurface surfaces;

public static:

    /**
        Pushes a surface to the stack
    */
    void push(WidgetSurface surface) {
        surfaces.add(surface);
    }

    /**
        Pops a surface off the stack
    */
    void pop() {
        surfaces.popBack;
    }

    /**
        Updates the last surface
    */
    void update() {
        surfaces.back().update();
    }

    /**
        Draws all the surfaces on the stack in order
    */
    void draw() {
        foreach(surface; surfaces) {
            surface.draw();
        }
    }
}

/**
    Initializes surface
*/
package(engine) void initSurface() {
    surfaceTex = new Texture(cast(ubyte[])import("border.png"));
    surfaceTex.setFiltering(Filtering.Point);
    borderTileSize = surfaceTex.height/3;
    borderOffset = borderTileSize/2;
}

private {
    int borderOffset;
    int borderTileSize;
    Texture surfaceTex;
}

/**
    A surface where widgets are on
*/
class WidgetSurface {
protected:
    List!Widget children;
    float scrollOffset = 0;

    /**
        Sorts the children
    */
    void sortChildren() {
        import std.algorithm.sorting : sort;
        children.getArray().sort!"a.position.y < b.position.y";
    }

    bool showBorder;

public:
    /**
        The area of the surface
    */
    Rect area;

    /**
        Get amount of pixels to scroll the content
    */
    final float getScroll() {
        return scrollOffset;
    }

    /**
        Gets the viewport
    */
    Rect getViewport() {
        return area.displace(cast(int)scrollOffset, 0);
    }

    void setShowBorder(bool show) {
        this.showBorder = show;
    }

    /**
        Gets the area of the content inside the surface

        TODO: make it calculate width as well
    */
    Rect getContentArea() {
        Widget bottomChild = children.back();
        vec2i pos = bottomChild.position;
        vec2 size = bottomChild.getSize();
        return Rect(area.x, area.y, area.width, pos.y+cast(int)size.y);
    }

    /**
        Constructor
    */
    this(Rect area, Widget[] children = null, bool showBorder = true) {
        this.area = area;
        this.scrollOffset = 0;
        this.showBorder = showBorder;

        foreach(child; children) this.add(child);
    }

    /**
        Adds a child and resorts the child list
    */
    final void add(Widget widget) {
        children.add(widget);
        widget.setSurface(this);
        this.sortChildren();
    }

    /**
        Updates the surface
    */
    void update() {
        // Iterate over children
        foreach(child; children) {
            child.update();
        }
    }

    /**
        Draws the surface
    */
    void draw() { 

        if (showBorder) {
            // Top left
            GameBatch.draw(
                surfaceTex, 
                vec4(area.left-borderOffset, area.top-borderOffset, borderTileSize, borderTileSize), 
                vec4(0, 0, borderTileSize, borderTileSize)
            );

            // Top right
            GameBatch.draw(
                surfaceTex, 
                vec4(area.right-borderOffset, area.top-borderOffset, borderTileSize, borderTileSize), 
                vec4(borderTileSize*2, 0, borderTileSize, borderTileSize)
            );

            // Bottom left
            GameBatch.draw(
                surfaceTex, 
                vec4(area.left-borderOffset, area.bottom-borderOffset, borderTileSize, borderTileSize), 
                vec4(0, borderTileSize*2, borderTileSize, borderTileSize)
            );

            // Bottom right
            GameBatch.draw(
                surfaceTex, 
                vec4(area.right-borderOffset, area.bottom-borderOffset, borderTileSize, borderTileSize), 
                vec4(borderTileSize*2, borderTileSize*2, borderTileSize, borderTileSize)
            );

            // Top
            GameBatch.draw(
                surfaceTex, 
                vec4(area.left+borderOffset, area.top-borderOffset, area.width-borderTileSize, borderTileSize), 
                vec4(borderTileSize, 0, borderTileSize, borderTileSize)
            );

            // Right
            GameBatch.draw(
                surfaceTex, 
                vec4(area.right-borderOffset, area.top+borderOffset, borderTileSize, area.height-borderTileSize), 
                vec4(borderTileSize*2, borderTileSize, borderTileSize, borderTileSize)
            );

            // Bottom
            GameBatch.draw(
                surfaceTex, 
                vec4(area.left+borderOffset, area.bottom-borderOffset, area.width-borderTileSize, borderTileSize), 
                vec4(borderTileSize, borderTileSize*2, borderTileSize, borderTileSize)
            );

            // Left
            GameBatch.draw(
                surfaceTex, 
                vec4(area.left-borderOffset, area.top+borderOffset, borderTileSize, area.height-borderTileSize), 
                vec4(0, borderTileSize, borderTileSize, borderTileSize)
            );

            // Fill
            GameBatch.draw(
                surfaceTex, 
                vec4(area.left+borderOffset, area.top+borderOffset, area.width-borderTileSize, area.height-borderTileSize), 
                vec4(borderTileSize, borderTileSize, borderTileSize, borderTileSize)
            );
            GameBatch.flush();
        }

        UI.begin();
        UI.setScissor(area);

        // Draw all the children
        foreach(child; children) {
            if (child.visible) child.draw();
        }

        UI.end();
    }
}

/**
    An interactive widget surface.

    For interactive widgets
*/
class InWidgetSurface : WidgetSurface {
private:
    float targetScroll = 0;
    size_t activeWidget;

    // true = up, false = down
    Widget getWidgetToFocus(bool direction) {
        if (direction) {
            // Fallback
            if (activeWidget <= 0) return children[activeWidget];

            size_t toFocus = activeWidget;
            while(toFocus > 0 && !children[toFocus-1].interactible) toFocus--;
            return children[toFocus];
        }
        else return children[activeWidget];
    }

    // true = up, false = down
    void recalcScroll(bool direction) {

        Widget toFocus = getWidgetToFocus(direction);

        auto widgetPosition = toFocus.position;
        auto widgetSize = toFocus.getSize();
        
        // The viewport
        Rect viewport = getViewport();
        
        // The size of the content
        Rect contentArea = getContentArea();

        // If the widget top or bottom is outside the viewport
        // Note: I'm not sure why but we need to add 8 pixels to the widget size
        if (scrollOffset+viewport.height <= widgetPosition.y+widgetSize.y ||
            scrollOffset >= widgetPosition.y) {
            
            targetScroll = clamp(
                direction ?
                    widgetPosition.y : // up
                    (widgetPosition.y-viewport.height) + widgetSize.y+8, // down
                0,
                (contentArea.height-viewport.height)+8
            );
        }
    }

public:
    /**

    */
    this(Rect area, Widget[] children = null) {
        super(area, children);
        this.targetScroll = 0;

        /**
            Move to first widget
        */
        this.first();
        this.current().hover();
    }

    /**
        Gets the current active widget
    */
    final Widget current() {
        return children[activeWidget];
    }

    /**
        Move to next widget
    */
    final Widget next() {

        // Can't move between no children
        if (children.count == 0) return null;

        activeWidget++;
        
        // Move to last element if we've gone past the end
        if (activeWidget >= children.count) activeWidget = 0;

        // Skip widgets we can't interact with anyways
        if (!children[activeWidget].interactible) next();

        // Return the active widget
        return children[activeWidget];
    }

    /**
        Move to previous widget
    */
    final Widget prev() {

        // Can't move between no children
        if (children.count == 0) return null;

        // Dark magic
        ptrdiff_t aWidget = cast(ptrdiff_t)activeWidget;
        activeWidget = aWidget-1 < 0 ? children.count()-1 : activeWidget-1;

        // Skip widgets we can't interact with anyways
        if (!children[activeWidget].interactible) prev();

        // Return the active widget
        return children[activeWidget];
    }

    /**
        Move to the first widget
    */
    final Widget first() {
        activeWidget = 0;

        // Can't move between no children
        if (children.count == 0) return null;

        // Skip widgets we can't interact with anyways
        if (!children[activeWidget].interactible) next();

        // Return the active widget
        return children[activeWidget];
    }
    
    override void update() {
        
        // Dampen the scroll to the desired position
        // TODO: Do something better here
        scrollOffset = round(dampen!float(scrollOffset, targetScroll, deltaTime(), 1));

        // Move between children
        if (UI.isKeyPressed(Key.KeyUp)) {
            this.current().leave();
            this.prev().hover();

            this.recalcScroll(true);
        } else if (UI.isKeyPressed(Key.KeyDown)) {
            this.current().leave();
            this.next().hover();

            this.recalcScroll(false);
        }

        // Only update the active widget
        foreach(child; children) {
            child.update();
        }
    }
}