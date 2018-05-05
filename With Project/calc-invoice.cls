%Adapted by RedWarbler from dapper-invoice.cls by mkropat under MIT license

\ProvidesClass{calc-invoice}[2015/04/12]
\NeedsTeXFormat{LaTeX2e}
\LoadClass[11pt]{article}

% For page number calculations and currency symbol selection
\RequirePackage{ifthen}

% To handle key=value options in class definition
\RequirePackage{kvoptions}
\SetupKeyvalOptions{prefix=dapper@}

\DeclareStringOption[dollar]{currency}[dollar]
\ProcessKeyvalOptions*

\RequirePackage{eurosym}

\ifthenelse{\equal{\dapper@currency}{dollar}}{\newcommand{\currencysym}{\$}}{}
\ifthenelse{\equal{\dapper@currency}{euro}}{\newcommand{\currencysym}{\euro}}{}
\ifthenelse{\equal{\dapper@currency}{pound}}{\newcommand{\currencysym}{\textsterling}}{}

\RequirePackage[hidelinks]{hyperref}% For links and metadata
\RequirePackage{soul}% For adjusting letter spacing
\RequirePackage{xcolor}
\RequirePackage{etoolbox}% For "At*" hooks
\RequirePackage{fancyhdr}% For adjusting footer
\RequirePackage{longtable}% For tables
\RequirePackage{datenumber}% Caluclating due date
\RequirePackage{tikz}% Drawing the arrow
\usetikzlibrary{calc}
\usetikzlibrary{fpu}
\RequirePackage{fp}% For invoice math
\RequirePackage{enumitem}% Customizing lists
\RequirePackage{siunitx}% Formatting numbers
\RequirePackage{fontspec}

\sisetup{round-integer-to-decimal, group-separator={,}}

\defaultfontfeatures{Ligatures = TeX,
    Path = ./Fonts/}

\IfFileExists{./Fonts/OpenSans-Regular.ttf}{
    \setmainfont[ BoldFont = OpenSans-Bold, ItalicFont = OpenSans-Italic ]{OpenSans-Regular}
    \setsansfont[ BoldFont = OpenSans-Bold, ItalicFont = OpenSans-Italic ]{OpenSans-Regular}}{}

%%%%% Commands %%%%%

\newcommand*{\setmetadata}[4]{
    \hypersetup{
        bookmarksopen  = false,
        bookmarksdepth = 2,% to show sections and subsections
        pdfauthor      = {#1},
        pdftitle       = {#2 --- Invoice \##3 for #4},
        pdfsubject     = {Invoice \##3},
        pdfkeywords    = {invoice, expense, #4}}}

\newcommand*{\twocolumnlayout}[2]{
    \begin{tabular}[t]{@{} p{.5\linewidth} @{} p{.5\linewidth} @{}} #1 & #2 \end{tabular}
}
\sodef\invoiceSpacing{}{0em}{.4em}{.4em}
\newcommand*{\makeheader}[2]{
    \begin{minipage}[t]{.6\linewidth} {\headerStyle #1} \end{minipage}
    \hfill
    \begin{tabular}[t]{@{} c @{}}
        {\headerStyle \invoiceSpacing{Invoice} \##2} \\
        {\color{subduedColor} \gendate}
    \end{tabular}

    \addvspace{8ex}
}

\newcommand*{\duedate}[1]{%
    \setdatetoday%
    \addtocounter{datenumber}{#1}%
    \setdatebynumber{\thedatenumber}%
    \datedate%
}

\newcommand*{\infoSectionStyle}{\hspace{2em}}
\newcommand*{\infoSubStyle}{\small\slshape}

\newenvironment{infoSection}{\infoSectionStyle \tabular[t]{@{} r @{\hspace{0.5em}} l}}{\endtabular}
\newcommand{\infoBox}[2]{
    {\titleStyle #1} & \begin{minipage}[t]{.35\textwidth} #2 \end{minipage} \\
    \noalign{\addvspace{2ex}}
}
\newcommand{\infoSub}[2]{
    \noalign{\vspace{-1.8ex}}
    {\color{subduedColor} #1} & \begin{minipage}[t]{.35\textwidth} \infoSubStyle #2 \end{minipage} \\
    \noalign{\addvspace{2ex}}
}

\newcommand{\emaillink}[1]{%
    \href{mailto:#1}{#1}%
}

\newcommand*{\itemizationRowStyle}[0]{\small}
\newcommand*{\itemizationHeaderStyle}[0]{\normalsize\color{highlightColor}}

\newcounter{colskipcount}

\newenvironment{hoursItemization}{
    \setcounter{colskipcount}{5}
    \setlength\LTleft{0pt}
    \setlength\LTright{0pt}
    \begin{longtable}{c @{\hspace{1.5em}} p{.6\textwidth} r @{} l r r}
    \hline
    \noalign{\smallskip}
    {\itemizationHeaderStyle Date} &
    {\itemizationHeaderStyle Description} &
    \multicolumn{2}{l}{\itemizationHeaderStyle Hours} &
    {\itemizationHeaderStyle Rate} &
    {\itemizationHeaderStyle Amount}
    \\
    \noalign{\smallskip}
    \hline
    \noalign{\bigskip}
    \endhead
    \noalign{\bigskip}
    \hline
    \endfoot
    \endlastfoot
}{
    \end{longtable}
}

\newenvironment{hoursItemizationWithProject}{
    \setcounter{colskipcount}{6}
    \setlength\LTleft{0pt}
    \setlength\LTright{0pt}
    \begin{longtable}{c c @{\hspace{1.5em}} p{.5\textwidth} r @{} l r r}
    \hline
    \noalign{\smallskip}
    {\itemizationHeaderStyle Date} &
    {\itemizationHeaderStyle Project} &
    {\itemizationHeaderStyle Description} &
    \multicolumn{2}{l}{\itemizationHeaderStyle Hours} &
    {\itemizationHeaderStyle Rate} &
    {\itemizationHeaderStyle Amount}
    \\
    \noalign{\smallskip}
    \hline
    \noalign{\bigskip}
    \endhead
    \noalign{\bigskip}
    \hline
    \endfoot
    \endlastfoot
}{
    \end{longtable}
}

\gdef\InvoiceTotal{0}
\gdef\FinalBalance{0}

\newcommand*{\calcamount}[2]{%
    \FPmul\t{#1}{#2}%
    \formatcurrency{\t}%
    \FPadd\gt{\InvoiceTotal}{\t}%
    \global\let\InvoiceTotal\gt%
}

\newcommand*{\calcamounte}[1]{%
	\FPmul\t{1}{#1}%
	\formatcurrency{\t}%
	\FPadd\gt{\InvoiceTotal}{\t}%
	\global\let\InvoiceTotal\gt%
}

\newcommand{\balancedue}{\FPeval\balresult{\InvoiceTotal - \paid}
	\FPadd\fb{\FinalBalance}{\balresult}%
	\global\let\FinalBalance\fb
}

\newcommand*\@formatFraction[1]{
    \ifnum\Numerator=25 ¼\fi%
    \ifnum\Numerator=50 ½\fi%
    \ifnum\Numerator=75 ¾\fi%
}

\newcommand*\@formatHoursLeft[1]{
    \pgfmathtruncatemacro{\WholePortion}{int(#1)}%
    \pgfmathtruncatemacro{\Numerator}{100*(#1-\WholePortion)}%
    \ifnum\WholePortion=0%
        \@formatFraction{\Numerator}%
    \else%
        \WholePortion%
    \fi%
}

\newcommand*\@formatHoursRight[1]{
    \pgfmathtruncatemacro{\WholePortion}{int(#1)}%
    \pgfmathtruncatemacro{\Numerator}{100*(#1-\WholePortion)}%
    \ifnum\WholePortion=0%
    \else%
        \@formatFraction{\Numerator}%
    \fi%
}

\newcommand{\hoursnp}[4]{
    {\itemizationRowStyle #1} &
    \begin{minipage}[t]{.5\textwidth}
        \begin{itemize}[leftmargin=0pt, labelsep=1pt, itemsep=0pt] \itemizationRowStyle #4 \end{itemize}
    \end{minipage} &
    {\itemizationRowStyle \@formatHoursLeft{#2}} &
    {\itemizationRowStyle \@formatHoursRight{#2}} &
    {\itemizationRowStyle \currencysym#3} &
    {\itemizationRowStyle \currencysym\calcamount{#2}{#3}}
    \\
    \noalign{\medskip}
}

\newcommand{\expensenp}[3]{
	{\itemizationRowStyle #1} &
	\begin{minipage}[t]{.5\textwidth}
		\begin{itemize}[leftmargin=0pt, labelsep=1pt, itemsep=0pt] \itemizationRowStyle #3 \end{itemize}
	\end{minipage} &
	{\itemizationRowStyle } &
	{\itemizationRowStyle } &
	{\itemizationRowStyle } &
	{\itemizationRowStyle \currencysym\calcamounte{#2}}
	\\
	\noalign{\medskip}
}

\newcommand{\hours}[5]{
    {\itemizationRowStyle #1} &
    {\itemizationRowStyle #4} &
    \begin{minipage}[t]{0.5\textwidth}
        \begin{itemize}[leftmargin=0pt, labelsep=1pt, itemsep=0pt] \itemizationRowStyle #5 \end{itemize}
    \end{minipage} &
    {\itemizationRowStyle \@formatHoursLeft{#2}} &
    {\itemizationRowStyle \@formatHoursRight{#2}} &
    {\itemizationRowStyle \currencysym#3} &
    {\itemizationRowStyle \currencysym\calcamount{#2}{#3}}
    \\
    \noalign{\medskip}
}

\newcommand{\expense}[4]{
	{\itemizationRowStyle #1} &
	{\itemizationRowStyle #3} &
	\begin{minipage}[t]{0.5\textwidth}
		\begin{itemize}[leftmargin=0pt, labelsep=1pt, itemsep=0pt] \itemizationRowStyle #4 \end{itemize}
	\end{minipage} &
	{\itemizationRowStyle  } &
	{\itemizationRowStyle  } &
	{\itemizationRowStyle  } &
	{\itemizationRowStyle \currencysym\calcamounte{#2}}
	\\
	\noalign{\medskip}
}

\newcommand{\beginsummary}{
    \noalign{\bigskip}
    \hline
    \noalign{\medskip}
}

\newcommand*{\summaryline}[2]{
    \multicolumn{\thecolskipcount}{r}{\itemizationHeaderStyle #1} & #2 \\
}

\newcommand*{\finalsummary}[2]{
	\multicolumn{\thecolskipcount}{r}{\itemizationHeaderStyle #1} &\balancedue #2 \\
}

\newcommand*{\tikzmark}[1]{\tikz[overlay,remember picture] \node ({#1}) {};}
\newcommand*{\arrowbase}{\tikzmark{@p1}}
\newcommand*{\arrowtarget}{\tikzmark{@p2}}
\newcommand*{\drawarrow}{
    \tikz[overlay,remember picture] {
        \draw[->,thick,color=subduedColor] ($(@p1)+(0.75em,1.5ex)$) -| ($(@p2)+(-2em,0.7ex)$) -- ($(@p2)+(-0.5em,0.7ex)$);}}

\newcommand*{\formatcurrency}[1]{%
    \num[group-separator={,}, group-minimum-digits=3, round-mode=places, round-precision=2]{#1}%
}

% Implementation by Werner (http://tex.stackexchange.com/a/176815/35707)
\newcommand*{\dectofrac}[1]{\begingroup%
  \pgfkeys{/pgf/number format/frac}% Format as fraction
  \let\frac\sfrac% Let \frac act like \sfrac
  \pgfmathprintnumber{#1}\endgroup}

% Debugging
\newcommand{\showbb}[1]{{\color{red!50}\leavevmode\rlap{\fbox{\phantom{#1}}}}#1}

%%%%% Styles %%%%%

\def\headerStyle{\Huge}
\def\titleStyle{\color{highlightColor}}
% Add page numbers
\fancypagestyle{plain}{
  \renewcommand{\headrulewidth}{0pt}
  \renewcommand{\footrulewidth}{0pt}
  \fancyhf{}}
% page numbers in footer if more than 1 page
% Copied from moderncv
\AtEndPreamble{%
    \AtBeginDocument{%
        \@ifundefined{r@lastpage}{}{%
            \ifthenelse{\pageref{lastpage}>1}{%
                \newlength{\pagenumberwidth}%
                \settowidth{\pagenumberwidth}{\thepage/\pageref{lastpage}}%
                \fancypagestyle{plain}{%
                    \fancyfoot[r]{\parbox[b]{\pagenumberwidth}{\thepage/\pageref{lastpage}}}%
                }%
                \pagestyle{plain}%
            }{}%
        }%
        \AtEndDocument{\label{lastpage}}%
    }%
}
\pagestyle{plain}

\setlength{\parindent}{0pt}% Disable paragraph indent
