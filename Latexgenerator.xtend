package org.xtext.example.mydsl.generator

import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.emf.ecore.resource.Resource
import org.xtext.example.mydsl.anislide.Template
import org.xtext.example.mydsl.generator.AnislideGenerator;
import org.xtext.example.mydsl.anislide.Global
import org.xtext.example.mydsl.anislide.Slide
import org.xtext.example.mydsl.anislide.Title
import org.xtext.example.mydsl.anislide.Tmplt
import org.xtext.example.mydsl.anislide.ProgressAnimation
import org.xtext.example.mydsl.anislide.Textcolor
import org.xtext.example.mydsl.anislide.BackgroundColor
import org.xtext.example.mydsl.anislide.Progresstype
import org.xtext.example.mydsl.anislide.Progressanim
import org.xtext.example.mydsl.anislide.Height
import org.xtext.example.mydsl.anislide.Width
import org.xtext.example.mydsl.anislide.Animate

class Latexgenerator extends AnislideGenerator  {
	new(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		initialise(resource, fsa, context);
		fsa.generateFile(title + ".tex", generateDocument());

	}
	
	int colorCount = 0;
	boolean constantIsCreated = false;
	
	def generateDocument() {
		'''
		% #########################
		% # GENERATED BY AniSlide #
		% #########################
		
		\documentclass{beamer}
		\usepackage{xcolor}
		\usepackage{tikz}
		\usetikzlibrary{calc}
		�FOR global : model.global�
		�global.generateGlobal�
		�ENDFOR�
		
		�FOR progressani : model.progressanimations�
		�progressani.generateProgress�
		�ENDFOR�
		
		�FOR template : model.templates�
		�template.generateTemplate�
		�ENDFOR�
		\begin{document}
		�FOR slide : model.slides�
		�slide.generateSlide�
		�ENDFOR�
		
		\end{document}
		'''
	}
	
	def generateProgress(ProgressAnimation progressani) {
		'''
		\def\progressbar@�progressani.name�{}

		�IF constantIsCreated==false�
		\makeatletter 
		\definecolor{pbblue}{HTML}{0A75A8}% color for the progress bar
		\definecolor{pbgray}{HTML}{575757}% background color for the progress bar
		
		\newcount\progressbar@tmpcounta % auxiliary counter
		\newcount\progressbar@tmpcountb % auxiliary counter
		
		\newdimen\progressbar@pbht %progressbar height
		\newdimen\progressbar@pbwd %progressbar width
		\newdimen\progressbar@tmpdim %auxiliary dimension
		
		�{constantIsCreated = true; ""}�
		�ENDIF�

		�FOR entity : progressani.progressbody.progressentities��IF entity.key=="type:"�
			�IF entity.getValue=="image"�
					\def\progressbar@�progressani.name�{
					    \pgfmathparse{int(round(\insertframenumber-1))}
					    \progressbar@tmpcounta= \pgfmathresult
					    
					    \pgfmathparse{int(round(\inserttotalframenumber-1))}
					    \progressbar@tmpcountb=\pgfmathresult
					    
						�FOR e : progressani.progressbody.progressentities�
							�e.generateProgressEntity�
						�ENDFOR�					    
					    \progressbar@tmpdim=.5\progressbar@pbwd
					    \multiply\progressbar@tmpdim by \progressbar@tmpcounta
					    \divide\progressbar@tmpdim by \progressbar@tmpcountb
					    \progressbar@tmpdim=2\progressbar@tmpdim
					
					  \begin{tikzpicture}[overlay, remember picture,shift={($(current page.south west)+(1,1)$)}]
					  
					    \draw[pbblue!30,line width=\progressbar@pbht]
					      (0,0) -- ++ (\progressbar@pbwd,0pt);
					
					    \node[inner sep=1pt] at (\the\dimexpr\progressbar@tmpdim, .\progressbar@pbht)
					    {\includegraphics[width=\progressbar@rimage]{apple.jpg}};
					    
					  \end{tikzpicture}%
					}

					\setbeamertemplate{�progressani.name�}
					{
					  \begin{beamercolorbox}[wd=\paperwidth,ht=4ex,center,dp=1ex]{white}%
					    \progressbar@�progressani.name�%
					  \end{beamercolorbox}%
					}
			�ELSEIF entity.getValue=="rectangle"�
					\def\progressbar@�progressani.name�{% 
					
					    \pgfmathparse{int(round(\insertframenumber-1))}
					    \progressbar@tmpcounta= \pgfmathresult
					    
					    \pgfmathparse{int(round(\inserttotalframenumber-1))}
					    \progressbar@tmpcountb=\pgfmathresult
						�FOR e : progressani.progressbody.progressentities�
							�e.generateProgressEntity�
						�ENDFOR�					    
					
					    \progressbar@tmpdim=\progressbar@pbwd
					    \multiply\progressbar@tmpdim by \progressbar@tmpcounta
					    \divide\progressbar@tmpdim by \progressbar@tmpcountb
					
					  	\begin{tikzpicture}[overlay, remember picture,shift={($(current page.south west)+(1,1)$)}, rounded corners=2pt,very thin]
					
					    \shade[top color=pbgray!20,bottom color=pbgray!20,middle color=pbgray!50]
					      (0pt, 0pt) rectangle ++ (\progressbar@pbwd, \progressbar@pbht);
					
					      \shade[draw=pbblue,top color=pbblue!50,bottom color=pbblue!50,middle color=pbblue] %
					        (0pt, 0pt) rectangle ++ (\progressbar@tmpdim, \progressbar@pbht);
					
					    \draw[color=normal text.fg!50]  
					      (0pt, 0pt) rectangle (\progressbar@pbwd, \progressbar@pbht) 
					        node[pos=0.5,color=black] {\textnormal{%
					             \insertframenumber/\inserttotalframenumber%
					        }%
					    };
					  \end{tikzpicture}%
					}
					
					\setbeamertemplate{�progressani.name�}
					{
					  \begin{beamercolorbox}[wd=\paperwidth,ht=4ex,center,dp=1ex]{white}%
					    \progressbar@�progressani.name�%
					  \end{beamercolorbox}%
					}
			�ENDIF�
			�ENDIF�
		�ENDFOR�
		
		'''
	}
	def generateGlobal(Global global) {
		'''
		% #########################
		% #  GLOBAL STYLE         #
		% #########################
		�FOR style : global.globalbody.styles�
				�style.generateGlobalEntity�
		�ENDFOR�
		
		\BeforeBeginEnvironment{frame}{%
	    	�FOR style : global.globalbody.styles�
  				�style.generateGlobalStyle�
      		�ENDFOR�
		}
		% #########################
		
		'''
	}
	def generateTemplate(Template template) {
		colorCount++;
		'''
		% #########################
		% #  TEMPLATE �template.name.toUpperCase� #
		% #########################
		\defbeamertemplate*{background canvas}{�template.name�}
		�FOR style : template.templatebody.styles�
				�style.generateTemplateEntity�
		�ENDFOR�
		
		\makeatletter
		\define@key{beamerframe}{�template.name�}[true]{%
		\setbeamertemplate{background canvas}[�template.name�]
	    �FOR style : template.templatebody.styles�
  			�style.generateTemplateStyle�
      	�ENDFOR�
		}
		% #########################
		'''
	}
	def generateSlide(Slide slide) {		
		'''
		{
		�FOR style : slide.slidebody.styles�
				�style.generate�
		�ENDFOR�
		\begin{frame}�FOR entity : slide.slidebody.slideentities��IF entity.key == "template:"��entity.generate��ENDIF��ENDFOR�
		�FOR entity : slide.slidebody.slideentities�
			�IF entity.key != "template:"�
				�entity.generate�
			�ENDIF�
		�ENDFOR�
		Write your text hereeee :)
		\end{frame}
		}
		'''
	}
	def dispatch generate(Title entity) {
		''' 
		\frametitle{�entity.value�}
		'''
	}
	def dispatch generate(Tmplt entity) {
		'''[�entity.value.name�]'''
	}
	def dispatch generate(Textcolor entity) {
		''' 
		\definecolor{TempText}{RGB}{�entity.value�}
		\setbeamercolor{normal text}{fg=TempText}
		'''
	}
	def dispatch generate(BackgroundColor entity) {
		''' 
		\definecolor{TempBG}{�entity.value�}
		\setbeamercolor{background canvas}{bg=TempBG}
		''' 
	}
	
	def dispatch generate(Progressanim	entity){
		'''
		\usebeamertemplate{�entity.value.name�}
		'''
	}
	
	def dispatch generateGlobalEntity(BackgroundColor entity) {
		''' 
		\defbeamertemplate*{background canvas}{global}
		{		    
			\definecolor{bgcolor}{rgb}{�entity.value�}\color{bgcolor}\vrule width\paperwidth height\paperheight
		}
		''' 
	}
	def dispatch generateGlobalEntity(Textcolor entity) {
		'''
		\definecolor{textcolor}{rgb}{�entity.value�}
		'''
	}
	def dispatch generateTemplateEntity(BackgroundColor entity) {
		'''
		{
			\definecolor{bgcolor}{rgb}{�entity.value�}\color{bgcolor}\vrule width\paperwidth height\paperheight
		}
		'''
	}
	def dispatch generateTemplateEntity(Textcolor entity) {
		'''
		\definecolor{textcolor�colorCount�}{rgb}{�entity.value�}
		'''
	}
	
	def dispatch generateProgressEntity(Progresstype entity) {
		'''
		�IF entity.value == "image"�
		\newdimen\progressbar@rimage
		\progressbar@rimage=10px
		�ELSEIF entity.value == "rectangle"�
		�ENDIF�
		'''
	}
	

	
	def dispatch generateProgressEntity(Animate entity) {
		'''
		�FOR option : entity.value�
			�option.generateProgressOptions�
		�ENDFOR�
		'''
	}
	
	
	def dispatch generateProgressOptions(Width entity) {
		'''
		�IF entity.unit == "%"�
		\pgfmathparse{(0.01*�entity.value�))}
		\progressbar@pbwd= \pgfmathresult \linewidth
		�ELSE�
		\progressbar@pbwd=�entity.value��entity.unit�
		�ENDIF�
		'''
	}
	
	def dispatch generateProgressOptions(Height entity) {
		'''
		�IF entity.unit == "%"�
		\pgfmathparse{(0.01*�entity.value�))}
		\progressbar@pbht= \pgfmathresult \paperheight
		�ELSE�
		\progressbar@pbht=�entity.value��entity.unit�
		�ENDIF�
		'''
	}
	
	
	def dispatch getValue(Progresstype entity) {
		return entity.value;
	}
	
	def dispatch getValue(Textcolor entity) {
		return entity;
	}
	
	
	def dispatch generateGlobalStyle(BackgroundColor entity) {
		'''
		\setbeamertemplate{background canvas}[global]
		'''
	}
	def dispatch generateGlobalStyle(Textcolor entity) {
		'''
		\color{textcolor}
		'''	
	}
	def dispatch generateTemplateStyle(BackgroundColor entity) {
		'''
		'''
	}
	def dispatch generateTemplateStyle(Textcolor entity) {
		'''
		\color{textcolor�colorCount�}
		'''	
	}
	def generateTemplateName(Tmplt templatename) {
		'''	[test] '''
	}
}