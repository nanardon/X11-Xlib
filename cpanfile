requires 'ExtUtils::MakeMaker' => "0";
requires 'Test::More'          => "0";
requires 'Devel::CheckLib'     => "1.03";
requires "ExtUtils::Depends"   => "0.405";
requires "Try::Tiny"           => "0";

on test => sub {
  requires 'Test::TempDir::Tiny';
  requires 'Test::More' => 1.001014;
};