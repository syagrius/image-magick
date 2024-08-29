unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.ListBox;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    GravityCombo: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var

  Form1: TForm1;

implementation

uses
  System.IOUtils,
  LiteBitmap,
  LiteBitmap.ImageMagick, ImageMagick.Wand, ImageMagick;

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
  LLiteBitmap: IipLiteBitmap;
  Ratio:Double;
begin
  LLiteBitmap := TipImageMagickLiteBitmap.Create(TFile.ReadAllBytes('.\photos\piclumen-1724960425471.png'));
  //LLiteBitmap := TipImageMagickLiteBitmap.Create(TFile.ReadAllBytes('.\photos\piclumen-1724960425471.png'), TRect.Create(372, 159, 612, 399));

  Ratio := LLiteBitmap.Width / LLiteBitmap.Height;
  LLiteBitmap.Resize(Round(800 * Ratio), 800, TipScaleAlgorithm.Lanczos,1000,900, EastGravity, 'yellow');

  TFile.WriteAllBytes('.\photos\output_image.png', LLiteBitmap.ToBytes(TipImageFormat.Jpg, 90));
  //Showmessage(Format('Saved "%s"!', [TPath.GetFullPath('..\..\..\output_image.png')]));

  Image1.Bitmap.LoadFromFile(TPath.GetFullPath('.\photos\output_image.png'));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Is necessary to load/unload the dll manually. The dll load is dynamic/manual
  // to avoid delphi attempt to load the dll, for exmple, when you make a
  // package that is using the image magick and install it
  if not TipImageMagickLiteBitmap.TryInitializeLibrary then
    Showmessage('Cannot possible to find the ImageMagick dlls. Please make sure that the ImageMagick is installed! Maybe your ImageMagick is 32 bits and this program is 64 bits or vice versa.');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  // Is necessary to load/unload the dll manually. The dll load is dynamic/manual
  // to avoid delphi attempt to load the dll, for exmple, when you make a
  // package that is using the image magick and install it
  TipImageMagickLiteBitmap.FinalizeLibrary;
end;

end.
