# License

Gigayak Linux is covered by the Apache Public License, version 2.0, as
follows:

> Copyright 2015-2017 John Gilik
>
> Licensed under the Apache License, Version 2.0 (the "License");
> you may not use this file except in compliance with the License.
> You may obtain a copy of the License at
>
>     http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software
> distributed under the License is distributed on an "AS IS" BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
> See the License for the specific language governing permissions and
> limitations under the License.

Files that do not contain any comment at the top indicating "Additional licenses
apply to this file." are covered solely by the above license.


# Attributions

Many pieces of Gigayak Linux were based off of open-source work published under
permissive licenses, which require attribution.  The following sections identify
where these parts of Gigayak came from, as well as how to identify them.


## (Cross) Linux From Scratch instructions

Many of the base package instructions are derived from the Linux From Scratch
family of books, subjecting them to the MIT license in that book:

> Copyright 1999-2015 Gerard Beekmans
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of
> this software and associated documentation files (the "Software"), to deal in the
> Software without restriction, including without limitation the rights to use,
> copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
> Software, and to permit persons to whom the Software is furnished to do so,
> subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
> FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
> COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
> AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
> WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

In most cases, both the Linux From Scratch book as well as the Cross Linux From
Scratch books were consulted, meaning that these files are also covered under
the CLFS license:

> Copyright 2005-2014 by Joe Ciccone, Jim Gifford & Ryan Oliver. This material may be
> distributed only subject to the terms and conditions set forth in the Open
> Publication License, v1.0 or later (the latest version is presently available
> at http://www.opencontent.org/openpub/).

Files matching these license(s) have been labeled with a comment indicating that
they are derivative works of LFS and CLFS.  Use `grep -R 'derivative of the LFS
and CLFS books' <directory containing this file>` to find affected files.

## cURL / ca-certificates instructions

The `ca-certificates` package instructions are derived from the cURL source
code, which is distributed under the MIT license:

> COPYRIGHT AND PERMISSION NOTICE
>
> Copyright (c) 1996 - 2016, Daniel Stenberg, <daniel@haxx.se>.
>
> All rights reserved.
>
> Permission to use, copy, modify, and distribute this software for any purpose
> with or without fee is hereby granted, provided that the above copyright
> notice and this permission notice appear in all copies.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD PARTY RIGHTS. IN
> NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
> DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
> OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
> OR OTHER DEALINGS IN THE SOFTWARE.
>
> Except as contained in this notice, the name of a copyright holder shall not
> be used in advertising or otherwise to promote the sale, use or other dealings
> in this Software without prior written authorization of the copyright holder.

Files matching this license have been labeled with a comment indicating that
they are derivative of cURL packaging scripts.  Use `grep -R 'derivative of
cURL' <directory containing this file>` to find affected files.
