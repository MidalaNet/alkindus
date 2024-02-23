
/* 
 * Alkindus
 * GTK+ PDF reader
 *
 */

using Gtk;

// Class PdfReader
public class PdfReader : GLib.Object {

  private Poppler.Document pdf;
  private string document;
  private int index;
  private int ptotal;
  private double ratio = 1.0;
  public Gtk.Window window {
    get; set;
  }
  public Gtk.Image image;
  public Gtk.Statusbar statusbar;

  // Constructor
  public PdfReader () {
    
    try {
      Gtk.Builder builder = new Gtk.Builder ();
              
      builder.add_from_file ("/usr/local/share/alkindus/main.ui");
      
      window = builder.get_object ("window") as Gtk.Window;
      this.image = builder.get_object ("image1") as Gtk.Image;
      this.statusbar = builder.get_object ("statusbar1") as Gtk.Statusbar;
                      
      window.destroy.connect (Gtk.main_quit);
      builder.connect_signals (this);
                        
    } catch (Error e) {
    
          stderr.printf ("Could not load UI: %s", e.message);
    }
  }
  
  [CCode (instance_pos = -1)]
  public void on_menuabout_activate (Gtk.Widget source)
  {
    var dialog = new Gtk.MessageDialog (
      null, 
      Gtk.DialogFlags.DESTROY_WITH_PARENT | Gtk.DialogFlags.MODAL, 
      Gtk.MessageType.INFO, 
      Gtk.ButtonsType.CLOSE, ("Alkindus\nGTK+ PDF reader\n\nWritten in Vala for Linux environments, this is a very lightweight PDF document reader. Released under the GPLv3 licence, it is free software.")
    );
    dialog.title = "GTK+ PDF reader";
    dialog.run ();
    dialog.destroy (); 
  }
  
  [CCode (instance_pos = -1)]
  public void on_buttonzoomin_clicked (Gtk.Widget source) {   
    
    this.ratio = this.ratio + 0.5;   
    reader (this.document, this.ratio);
  }
  
  [CCode (instance_pos = -1)]
  public void on_buttonzoomout_clicked (Gtk.Widget source) {   
    
    
    if (this.ratio > 0.5) {
    
      this.ratio = this.ratio - 0.5;
      reader (this.document, this.ratio);
    }
  }
  
  [CCode (instance_pos = -1)]
  public void on_buttonpagefwd_clicked (Gtk.Widget source) {   
    
    if ((this.index + 1) < this.ptotal) {
      this.index++;
    } else {
      if ((this.index + 1) == this.ptotal) {
        this.index = 0;
      } else {
        this.index--;
      }
    }
    reader (this.document, this.ratio);
  }
  
  [CCode (instance_pos = -1)]
  public void on_buttonpageback_clicked (Gtk.Widget source) {   
    
    if (this.index > 0) {
      this.index--;
    } else {
      this.index = this.ptotal - 1;
    }
    reader (this.document, this.ratio);
  }
  
  [CCode (instance_pos = -1)]
  public void on_menuopen_activate (Gtk.Widget source) {
    
    var dialog = new FileChooserDialog (
      "GTK+ PDF Reader", 
      null, 
      FileChooserAction.OPEN, 
      "Cancel", 
      ResponseType.CANCEL, 
      "Open", 
      ResponseType.ACCEPT, 
      null
    );
    var filter = new FileFilter ();

		filter.set_name ("PDF Documents");
		filter.add_pattern ("*.pdf");
		dialog.add_filter (filter);
		dialog.set_filter (filter);
		dialog.set_select_multiple (false);

    if (dialog.run () == ResponseType.ACCEPT) {
    
      this.document = dialog.get_filename ();
      this.index = 0;
      reader (this.document, this.ratio);
    }
    
    dialog.destroy ();
  }

  public void reader (string document, double ratio) {  
    string msg; 
    double page_width, page_height;
    int twidth, theight;

    try {
      this.pdf = new Poppler.Document.from_file (Filename.to_uri (document), "");
      this.window.title = "Alkindus";//pdf.title; // + " (" + document + ")";
      this.ptotal = this.pdf.get_n_pages ();
      var page = this.pdf.get_page (this.index);
      int pnumber = this.index + 1;
      msg = "Page " + pnumber.to_string () + " of " + this.ptotal.to_string ();
      page.get_size(out page_width, out page_height);
      twidth = (int) (page_width * ratio);
      theight = (int) (page_height * ratio);
      var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, twidth, theight);
      var cr = new Cairo.Context (surface);
      cr.scale (ratio, ratio); // Aggiungi questa linea per applicare lo zoom
      page.render_for_printing (cr);
      var pixbuf = Gdk.pixbuf_get_from_surface (surface, 0, 0, twidth, theight);

      // Imposta l'immagine del widget Gtk.Image
      this.image.set_from_pixbuf (pixbuf);
    } catch (Error e) {
      msg = "Error: " + e.message;
    }

    this.statusbar.push (1, msg);
  }
}

void main (string[] args) {

  Gtk.init (ref args);
  
  PdfReader app = new PdfReader ();
  app.window.show_all ();

  Gtk.main ();

}