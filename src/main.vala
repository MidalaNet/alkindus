
/* 
 * alkindus
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
              
      builder.add_from_file ("main.ui");
      
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
      Gtk.ButtonsType.CLOSE, ("alkindus\nGTK+ PDF Reader\n\nCopyright (c) 2010, netico All rights reserved.")
    );
    dialog.title = "GTK+ PDF reader";
    dialog.run ();
    dialog.destroy (); 
  }
  
  [CCode (instance_pos = -1)]
  public void on_buttonzoomin_clicked (Gtk.Widget source) {   
    
    this.ratio = this.ratio + 0.5;   
    reader (this.document);
  }
  
  [CCode (instance_pos = -1)]
  public void on_buttonzoomout_clicked (Gtk.Widget source) {   
    
    
    if (this.ratio > 0.5) {
    
      this.ratio = this.ratio - 0.5;
      reader (this.document);
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
    reader (this.document);
  }
  
  [CCode (instance_pos = -1)]
  public void on_buttonpageback_clicked (Gtk.Widget source) {   
    
    if (this.index > 0) {
      this.index--;
    } else {
      this.index = this.ptotal - 1;
    }
    reader (this.document);
  }
  
  [CCode (instance_pos = -1)]
  public void on_menuopen_activate (Gtk.Widget source) {
    
    var dialog = new FileChooserDialog (
      "GTK+ PDF Reader", 
      null, 
      FileChooserAction.OPEN, 
      Stock.CANCEL, 
      ResponseType.CANCEL, 
      Stock.OPEN, 
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
      reader (this.document);
    }
    
    dialog.destroy ();
  }

  public void reader (string document) {  
  
    string msg; 
    double page_width, page_height;
    int twidth, theight;

    try {
    
      this.pdf = new Poppler.Document.from_file (Filename.to_uri (document), "");
      
      this.window.title = pdf.title + " (" + document + ")";
      
      this.ptotal = this.pdf.get_n_pages ();
      var page = this.pdf.get_page (this.index);
            
      int pnumber = this.index + 1;
      
      msg = "Page " + pnumber.to_string () + " of " + this.ptotal.to_string ();
      
      page.get_size(out page_width, out page_height);
      twidth = (int) (page_width * this.ratio);
      theight = (int) (page_height * this.ratio);
      
      var pixbuf = new Gdk.Pixbuf (Gdk.Colorspace.RGB, false, 8, twidth, theight);

      page.render_to_pixbuf (0, 0, twidth, theight, this.ratio, 0, pixbuf);
      
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